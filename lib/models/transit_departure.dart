// Class to store the departure time of a transit vehicle.
import 'dart:math';

import 'package:next_bus/models/transit_stop.dart';
import 'package:next_bus/models/transit_type.dart';

class TransitDeparture {
  // Direction is the destination of the train as well.
  final String direction;

  // Collection of all the next possible departures.
  final Set<DateTime> when;

  // Name of the line.
  final String name;

  // Type of transit.
  final TransitType transitType;

  // Is it a night-only transit?
  final bool isNight;

  // Is the current departure delayed?
  final int delay;

  // Name of the stop this departure is from.
  final String stopName;

  // Detailed information of the stop.
  TransitStop stop;

  TransitDeparture(
      {this.direction,
      this.name,
      this.when,
      this.transitType,
      this.isNight,
      this.delay,
      this.stopName,
      this.stop});

  factory TransitDeparture.fromJson(Map<String, dynamic> json) {
    int delay = json["line"]["delay"] == null ? 0 : json["line"]["delay"];
    DateTime departureTime;
    if (json['when'] != null) {
      departureTime =
          DateTime.parse(json['when']).add(Duration(minutes: delay));
    }
    TransitType type = TransitType.values.firstWhere(
        (e) => e.toString() == "TransitType.${json["line"]["product"]}");

    return TransitDeparture(
        direction: json["direction"],
        when: departureTime == null ? Set() : Set.from([departureTime]),
        name: json["line"]["name"],
        transitType: type,
        isNight: json["line"]["night"],
        delay: delay,
        stopName: json["stop"]["name"],
        stop: TransitStop.fromJson(json["stop"]));
  }

  // Description string printer for easy debugging.
  String description() {
    return "$name - $when - $direction - $transitType";
  }

  // Get up to 3 next departures as differential minute values from Now.
  List<int> nextDepartures() {
    var whenList = this.when.toList().sublist(0, min(3, this.when.length - 1));
    return whenList
        .map((transitDateTime) =>
            transitDateTime.difference(DateTime.now()).inMinutes)
        .toList();
  }
}

// Stores a list of transit departure.
class TransitDepartureList {
  final List<TransitDeparture> departures;

  TransitDepartureList({this.departures});

  factory TransitDepartureList.fromJson(List<dynamic> parsedJson) {
    List<TransitDeparture> departures = <TransitDeparture>[];
    departures = parsedJson.map((i) => TransitDeparture.fromJson(i)).toList();
    return new TransitDepartureList(
      departures: departures,
    );
  }

  // Description string printer for easy debugging.
  String description() {
    return departures.map((element) => element.description()).join("\n");
  }

  // Group same route number to the same destination as one departure with multiple "when".
  List<TransitDeparture> groupedDepartures() {
    Map<String, TransitDeparture> groupedDepartures = Map();
    for (TransitDeparture departure in this.departures) {
      if (departure.when.length <= 0) {
        continue;
      }
      var key = "${departure.name}/${departure.direction}";
      var currentDeparture = groupedDepartures.containsKey(key)
          ? groupedDepartures[key]
          : departure;
      currentDeparture.when.add(departure.when.first);
      groupedDepartures[key] = currentDeparture;
    }
    return groupedDepartures.values.toList();
  }
}
