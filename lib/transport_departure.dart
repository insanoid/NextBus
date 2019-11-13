/*Class to store the departure time of a transit vehicle.*/
class TransportDeparture {
  final String direction;
  final String when;
  final String name;
  final String transportType;
  final bool isNight;
  final String delay;

  TransportDeparture({this.direction, this.name, this.when, this.transportType, this.isNight, this.delay});

  factory TransportDeparture.fromJson(Map<String, dynamic> json) {
    return TransportDeparture(
      direction: json['direction'],
      when: json['when'],
      name: json['line']["name"],
      transportType: json['line']["product"],
      isNight: json['line']["night"],
      delay: json['line']["delay"],
    );
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
    departures = parsedJson.map((i)=>TransportDeparture.fromJson(i)).toList();
    return new TransportDepartureList(
      departures: departures,
    );
  }
  String description() {
    return departures.map((element) => element.description()).join("\n");
  }
}