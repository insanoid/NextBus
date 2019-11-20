// Stores minimal information about a single BVG transit stop.
class TransitStop {
  // ID of the stop that is used by the system to get further details about the stop.
  final String id;

  // Public name of the stop.
  final String name;

  // Distance from provided location in meters (if applicable).
  final int distance;

  // Lines of transit that pass through this stop.
  final List<dynamic> transitLines;

  // Coordinates for the transit.
  final double latitude, longitude;

  TransitStop({this.id, this.name, this.distance, this.transitLines, this.latitude, this.longitude});

  factory TransitStop.fromJson(Map<String, dynamic> json) {
    // We save the various lines passing through this stop.
    // We only need their names as further information can be fetched through departures.
    List<dynamic> lines = json["lines"] == null
        ? new List<dynamic>()
        : json["lines"].map((i) => i["name"]).toList();
    return TransitStop(
        id: json["id"],
        name: json["name"],
        distance: json["distance"],
        latitude: json["location"]["latitude"],
        longitude: json["location"]["longitude"],
        transitLines: lines);
  }

  // Formatted distance string with proper units.
  // @TODO: In the future we can add imperial and metric options.
  String formattedDistanceString() {
    return distance > 1000
        ? "${(distance / 1000.0).toStringAsFixed(1)} km"
        : "${distance}m";
  }

  // Description string printer for easy debugging.
  String description() {
    return "$id - $name - $distance - $transitLines";
  }
}

// Stores a list of transit stops and associated helper methods.
class TransitStopList {
  final List<TransitStop> stops;

  TransitStopList({this.stops});

  factory TransitStopList.fromJson(List<dynamic> parsedJson) {
    List<TransitStop> stops = new List<TransitStop>();
    stops = parsedJson.map((i) => TransitStop.fromJson(i)).toList();
    return new TransitStopList(
      stops: stops,
    );
  }

  // Not all stops are needed - we only need stops that have unique lines.
  // If a bus goes through 10 stops, we only care about the nearest stop to us.
  // The API already provides information sorted by distance so we only keep the first stop that we encounter for each unique route.
  List<dynamic> neededStops() {
    Map<String, TransitStop> routes = new Map();
    for (var stop in stops) {
      for (var line in stop.transitLines) {
        routes.putIfAbsent(line, () => stop);
      }
    }
    // Since there can be multiple unique lines at a given stop, we need to pick only the unique ones.
    return Set.from(routes.values).toList();
  }

  // Description string printer for easy debugging.
  String description() {
    return stops.map((element) => element.description()).join("\n");
  }
}
