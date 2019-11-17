import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:flutter/cupertino.dart';
import 'package:next_bus/models/transport_departure.dart';
import 'package:next_bus/models/transport_stop.dart';

import '../models/network_error.dart';

// A class to store all the API method and URL strings.
class APIMethods {
  static const String baseURL = "https://2.bvg.transport.rest/";
  static const String nearbyStopsAPI = "/stops/nearby";
  static String stopDeparturesAPI(String stopID) {
    return "stations/$stopID/departures";
  }
}

// API Client for all BVG related queries to be used as a singleton.
class BVGAPIClient {

  @protected Dio dioClient;
  static final BVGAPIClient _instance = BVGAPIClient._internal();

  factory BVGAPIClient() {
    return _instance;
  }

  BVGAPIClient._internal() {
    BaseOptions options = new BaseOptions(
      baseUrl: APIMethods.baseURL,
      connectTimeout: 5000,
      receiveTimeout: 3000,
    );
    dioClient = new Dio(options);
    dioClient.transformer = FlutterTransformer();
  }

  // Get all transit stops that are nearby the provided coordinates.
  // Returns an array of `TransportStop`.
  static Future getStops(double latitude, double longitude, {bool onlyNeeded = false}) async {
    try {
      Response response = await _instance.dioClient
          .get(APIMethods.nearbyStopsAPI, queryParameters: {
        "latitude": latitude,
        "longitude": longitude,
        "linesOfStops": true
      });
      var stopList = TransportStopList.fromJson(response.data);
      if(onlyNeeded) {
        return stopList.neededStops();
      }
      return stopList.stops;
    } on DioError catch (e) {
      return NetworkError.fromResponse(e.response);
    }
  }

  // Get all departures in the next 60 minutes from the provided stop ID.
  // Returns an array of `TransportDeparture`.
  static Future getDeparturesForStop(String stopID) async {
    try {
      Response response = await _instance.dioClient
          .get(APIMethods.stopDeparturesAPI(stopID), queryParameters: {"duration": 60});
      var departureList = TransportDepartureList.fromJson(response.data);
      return departureList.consolidatedDepartures();
    } on DioError catch (e) {
      return NetworkError.fromResponse(e.response);
    }
  }



  static Future getRelevantDepartures(double latitude, double longitude) async {

    var nearbyStops =  await getStops(latitude, longitude, onlyNeeded: true);
    if(nearbyStops.runtimeType == NetworkError) {
      print("Could not fetch stops ${nearbyStops.requestURL}");
      return nearbyStops;
    }

    Map<String, TransportDeparture> allDepartures = Map();

    for(TransportStop stop in nearbyStops) {
      print("Departures for ${stop.name}");
      var resultDeparture = await getDeparturesForStop(stop.id);
      if(resultDeparture.runtimeType == NetworkError) {
        print("Could not fetch stops ${resultDeparture.requestURL}");
      } else {
        for(TransportDeparture departure in resultDeparture) {
          if(departure.nextDepartures().length > 0) {
            var key = "${departure.name}/${departure.direction}";
            departure.stop = stop;
            allDepartures.putIfAbsent(key, () => departure);
          }
        }
      }
    }
    return allDepartures.values.toList();
  }

}