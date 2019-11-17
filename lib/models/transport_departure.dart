/*Class to store the departure time of a transit vehicle.*/
import 'dart:math';

import 'package:next_bus/models/transport_stop.dart';


class TransportDeparture {
  final String direction;
  final Set<String> when;
  final String name;
  final String transportType;
  final bool isNight;
  final String delay;
  final String stopName;
  TransportStop stop;

  TransportDeparture(
      {this.direction,
      this.name,
      this.when,
      this.transportType,
      this.isNight,
      this.delay,
      this.stopName,
      this.stop});

  factory TransportDeparture.fromJson(Map<String, dynamic> json) {
    return TransportDeparture(
        direction: json['direction'],
        when: Set.from([json['when']]),
        name: json['line']["name"],
        transportType: json['line']["product"],
        isNight: json['line']["night"],
        delay: json['line']["delay"],
        stopName: json['stop']['name'],
        stop: TransportStop.fromJson(json['stop']));
  }

  List<int> nextDepartures() {
    var whenList = this.when.toList().sublist(0, min(3, this.when.length - 1));
    return whenList
        .map((transitDateTime) => DateTime.parse(transitDateTime)
            .difference(DateTime.now())
            .inMinutes)
        .toList();
  }

  String description() {
    return "$name - $when - $direction - $transportType";
  }
}

/*Stores a list of transport departure.*/
class TransportDepartureList {
  final List<TransportDeparture> departures;

  TransportDepartureList({this.departures});

  factory TransportDepartureList.fromJson(List<dynamic> parsedJson) {
    List<TransportDeparture> departures = new List<TransportDeparture>();
    departures = parsedJson.map((i) => TransportDeparture.fromJson(i)).toList();
    return new TransportDepartureList(
      departures: departures,
    );
  }

  List<TransportDeparture> consolidatedDepartures() {
    Map<String, TransportDeparture> groupedDepartures = Map();
    for (TransportDeparture departure in this.departures) {
      var key = "${departure.name}/${departure.direction}";
      var currentDeparture = groupedDepartures.containsKey(key)
          ? groupedDepartures[key]
          : departure;
      currentDeparture.when.add(departure.when.first);
      groupedDepartures[key] = currentDeparture;
    }
    print(groupedDepartures);
    return groupedDepartures.values.toList();
  }

  String description() {
    return departures.map((element) => element.description()).join("\n");
  }
}
