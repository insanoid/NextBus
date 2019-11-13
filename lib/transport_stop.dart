/*Stores minimal information about a single BVG public transport stop.*/
class TransportStop {
  final String id;
  final String name;
  final int distance; // in meters.
  final List<dynamic> lines;

  TransportStop({this.id, this.name, this.distance, this.lines});

  factory TransportStop.fromJson(Map<String, dynamic> json) {
    // We save the various lines passing through this stop
    // WE only need their names so we can find the unique ones.
    List<dynamic> lines = new List<dynamic>();
    if (json["lines"] != null) {
      lines = json["lines"].map((i) => i["name"]).toList();
    }

    return TransportStop(
        id: json['id'],
        name: json['name'],
        distance: json['distance'],
        lines: lines);
  }

  String description() {
    return "$id - $name - $distance - $lines";
  }
}

/*Stores a list of transport stops.*/
class TransportStopList {
  final List<TransportStop> stops;

  TransportStopList({this.stops});

  factory TransportStopList.fromJson(List<dynamic> parsedJson) {
    List<TransportStop> stops = new List<TransportStop>();
    stops = parsedJson.map((i) => TransportStop.fromJson(i)).toList();
    return new TransportStopList(
      stops: stops,
    );
  }

  List<dynamic> neededStops() {
    Map<String, String> routes = new Map();
    for (var stop in stops) {
      for (var line in stop.lines) {
        routes.putIfAbsent(line, () => stop.name);
      }
    }
    // Since there can be multiple unique lines at a given stop, we need to pick only the unique ones.
    return Set.from(routes.values).toList();
  }

  String description() {
    return stops.map((element) => element.description()).join("\n");
  }
}
