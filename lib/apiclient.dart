import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:flutter/cupertino.dart';
import 'package:next_bus/transport_departure.dart';
import 'package:next_bus/transport_stop.dart';

abstract class BVGAPIClient {
  @protected
  Dio dioClient;
}

class BVGAPIClientInstance extends BVGAPIClient {
  static final BVGAPIClientInstance _instance =
      BVGAPIClientInstance._internal();

  factory BVGAPIClientInstance() {
    return _instance;
  }

  BVGAPIClientInstance._internal() {
    BaseOptions options = new BaseOptions(
      baseUrl: "https://2.bvg.transport.rest/",
      connectTimeout: 5000,
      receiveTimeout: 3000,
    );
    dioClient = new Dio(options);
    dioClient.transformer = FlutterTransformer();
  }

  static Future getStops(double latitude, double longitude) async {
    try {
      Response response = await _instance.dioClient.get("/stops/nearby",
          queryParameters: {
            "latitude": latitude,
            "longitude": longitude,
            "linesOfStops": true
          });
      var stopList = TransportStopList.fromJson(response.data);
      print(stopList.description());
      print(stopList.neededStops());
      return stopList.stops;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
        print(e.request.uri);
      } else {
        print(e.request);
        print(e.message);
      }
    }
  }

  static Future getDeparturesForStop(String stopID) async {
    ///stations/:id/departures
    Response response = await _instance.dioClient
        .get("stations/$stopID/departures", queryParameters: {"duration": 60});
    var departureList = TransportDepartureList.fromJson(response.data);
    print(departureList.description());
    return response.data.toString();
    // Get all possible departures from the given stop.
  }
}
