// Stores minimal information about a single BVG public transport stop.
class TransportStop {
  final String id;
  final String name;
  final int distance; // in meters.
  final List<dynamic> lines;

  TransportStop({this.id, this.name, this.distance, this.lines});

  factory TransportStop.fromJson(Map<String, dynamic> json) {
    // We save the various lines passing through this stop
    // We only need their names all the other information is irrelevant for the stop.
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

  String humanReadableDistance() {
    if(distance > 1000) {
      return "${(distance/1000.0).toStringAsFixed(1)} km";
    }
    return "${distance}m";
  }
  String description() {
    return "$id - $name - $distance - $lines";
  }
}

// Stores a list of transport stops and associated helper methods.
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

  // Not all stops are needed, we only need stops that have unique lines.
  // If a bus goes through 10 stops, we only care about the nearest stop to us.
  // The API already provides information sorted by distance so we only keep the first stop that we encounter for each unique route.
  List<dynamic> neededStops() {
    Map<String, TransportStop> routes = new Map();
    for (var stop in stops) {
      for (var line in stop.lines) {
        routes.putIfAbsent(line, () => stop);
      }
    }
    // Since there can be multiple unique lines at a given stop, we need to pick only the unique ones.
    return Set.from(routes.values).toList();
  }

  String description() {
    return stops.map((element) => element.description()).join("\n");
  }
}
