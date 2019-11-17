import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:flutter/cupertino.dart';
import 'package:next_bus/models/transit_departure.dart';
import 'package:next_bus/models/transit_stop.dart';
import '../models/network_error.dart';

// A class to store all the API method and URL strings.
class APIMethods {
  static const String baseURL = "https://2.bvg.transport.rest/";
  static const String nearbyStopsAPI = "/stops/nearby";

  static String stopDeparturesAPI(String stopID) {
    return "stations/$stopID/departures";
  }
}

const int DeparturesWithinDuration = 60;
const int MaximumStopsToConsider = 4;

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
  static Future getDeparturesNearby(double latitude, double longitude) async {
    // First we fetch all stops that are nearby and have unique lines.
    var stopsResult = await _getStops(latitude, longitude, onlyNeeded: true);
    if (stopsResult.runtimeType == NetworkError) {
      debugPrint("Failed Fetching Stops: ${stopsResult.requestURL}");
      return stopsResult;
    }

    Map<String, TransitDeparture> allDepartures = Map();

    var numberOfStopsAdded = 0;
    // Go through each stop, get departures for the stop.
    // Add unique routes for the given stop.
    // As the stops are sorted by distance the first stop with line is always the closest access to the line.
    for (TransitStop stop in stopsResult) {
      debugPrint("Departures For: ${stop.name}");

      var departureResult = await _getDepartures(stop.id);
      if (departureResult.runtimeType == NetworkError) {
        // @TODO: We should accumulate the errors in the future and show somethings didn't work out to the user.
        debugPrint("Failed Fetching Departure: ${departureResult.requestURL}");
        continue;
      }

      bool addedDeparturesFromStop = false;
      for (TransitDeparture departure in departureResult) {
        // Add only departures which have not been previously added to the list.
        // We consider one transit line only once (i.e. from the nearest stop).
        if (departure.nextDepartures().length > 0) {
          var key = "${departure.name}/${departure.direction}";
          // Save the stop details in the departure object as it is used to show distance from the user's location.
          departure.stop = stop;
          allDepartures.putIfAbsent(key, () => departure);
          addedDeparturesFromStop = true;
        }
      }

      if (addedDeparturesFromStop) {
        numberOfStopsAdded++;
      }
      // We only consider the first few stops since we do not want to overburden the user with information.
      if (numberOfStopsAdded >= MaximumStopsToConsider) {
        debugPrint("Stopping: Maximum Stops To Consider Limit Reached.");
        break;
      }
    }
    return allDepartures.values.toList();
  }
}
