import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:flutter/cupertino.dart';
import 'package:next_bus/models/multiple_request_response.dart';
import 'package:next_bus/models/transit_departure.dart';
import 'package:next_bus/models/transit_stop.dart';

import '../models/network_error.dart';

// A class to store all the API method and URL strings.
class APIMethods {
  static const String baseURL = "https://bvg-rest.karthikeyaudupa.now.sh/";
  static const String nearbyStopsAPI = "/stops/nearby";

  static String stopDeparturesAPI(String stopID) {
    return "stations/$stopID/departures";
  }
}

const int DeparturesWithinDuration = 60; // in minutes.

// API Client for all BVG related queries to be used as a singleton.
class BVGAPIClient {
  @protected
  Dio dioClient;
  static final BVGAPIClient _instance = BVGAPIClient._internal();

  factory BVGAPIClient() {
    return _instance;
  }

  BVGAPIClient._internal() {
    BaseOptions options = new BaseOptions(baseUrl: APIMethods.baseURL);
    dioClient = new Dio(options);
    dioClient.transformer = FlutterTransformer();
  }

  // Get all transit stops that are nearby the provided coordinates.
  // Returns an array of TransitStop.
  static Future _getStops(double latitude, double longitude,
      {bool onlyNeeded = false}) async {
    try {
      Response response = await _instance.dioClient
          .get(APIMethods.nearbyStopsAPI, queryParameters: {
        "latitude": latitude,
        "longitude": longitude,
        "linesOfStops": true
      });
      var stopList = TransitStopList.fromJson(response.data);
      return onlyNeeded ? stopList.neededStops() : stopList.stops;
    } on DioError catch (e) {
      return NetworkError.fromResponse(e.response);
    }
  }

  // Get all departures in the next 60 minutes from the provided stop ID.
  // Returns an array of TransitDeparture.
  static Future _getDepartures(String stopID) async {
    try {
      Response response = await _instance.dioClient.get(
          APIMethods.stopDeparturesAPI(stopID),
          queryParameters: {"duration": DeparturesWithinDuration});
      var departureList = TransitDepartureList.fromJson(response.data);
      return departureList.groupedDepartures();
    } on DioError catch (e) {
      return NetworkError.fromResponse(e.response);
    }
  }

  // get all the departures nearby with the only the closest stop for each transit line.
  static Future getDeparturesNearby(
      double latitude, double longitude) async {
    // First we fetch all stops that are nearby and have unique lines.
    var stopsResult = await _getStops(latitude, longitude, onlyNeeded: true);

    // If an error happens at this stage, there is nothing we can do but tell the user to try again.
    if (stopsResult.runtimeType == NetworkError) {
      debugPrint("Failed Fetching Stops: ${stopsResult.requestURL}");
      return MultipleRequestResponse(
          status: ResponseStatus.Failure, response: null, error: stopsResult);
    }

    // So now we have the list of stops, now we start getting departures for these stops.
    Map<String, TransitDeparture> allDepartures = Map();
    // Since there are multiple requests some might fail and some might work
    // We need to know if some failed to tell the user that the information he is shown might be incomplete.
    bool hasErrorsOccurred = false;
    // There might be stops but with no departures so we need to keep track of success.
    bool hasSuccessOccurred = false;

    // Since the departure response's stop data is not complete we need to keep a map of stop ID to stop data so we can use it later.
    Map<String, TransitStop> stopMap = new Map();
    List<Future> stopRequestList = new List();
    for (TransitStop stop in stopsResult) {
      stopMap[stop.id] = stop;
      stopRequestList.add(_getDepartures(stop.id));
    }
    debugPrint("Total Stops to Fetch: ${stopMap.length}");
    try {
      // Now we try all the async requests in parallel.
      // Some requests might come in early and some might come in late - distance sequence is no longer kept.
      List responses = await Future.wait(stopRequestList);

      for (var departureResult in responses) {
        // If there was a network error in one of the response we cannot do much about it but we can track it.
        if (departureResult.runtimeType == NetworkError) {
          debugPrint(
              "Failed Fetching Departure: ${departureResult.requestURL}");
          hasErrorsOccurred = true;
          continue;
        }
        hasSuccessOccurred = true;
        for (TransitDeparture departure in departureResult) {
          // We add departures to the list only if that line does not already have a departure from a stop closer to the user.
          if (departure.nextDepartures().length > 0) {
            var key = "${departure.name}/${departure.direction}";

            // Save the stop details in the departure object as it is used to show distance from the user's location.
            departure.stop = stopMap[departure.stop.id];
            var currentValue = allDepartures[key];
            // If the departure is not in the list OR it's from a stop closer to the user - save/replace it.
            if (currentValue == null ||
                currentValue.stop.distance > departure.stop.distance) {
              allDepartures[key] = departure;
            }
          }
        }
      }

      ResponseStatus status = ResponseStatus
          .OK; // if no error occurred and only success OR no error or success.
      if (hasSuccessOccurred && hasErrorsOccurred) {
        status = ResponseStatus.OKWithSomeFailures;
      } else if (!hasSuccessOccurred && hasErrorsOccurred) {
        status = ResponseStatus.Failure;
      }
      // We do not use the error, so we can always pass it as null for the time being.
      // If we do not have any departures or any stops a blank array is passed.

      var departureList = allDepartures.values.toList();
      // We sort the list by distance just to make sure nearest departures are shown first.
      departureList.sort((departure1, departure2) =>
          departure1.stop.distance.compareTo(departure2.stop.distance));
      return new MultipleRequestResponse(
          status: status, response: departureList, error: null);
    } catch (e) {
      debugPrint(
          "Something horribly went wrong. This error should never happen!");
      return new MultipleRequestResponse(
          status: ResponseStatus.Failure, response: null, error: null);
    }
  }
}
