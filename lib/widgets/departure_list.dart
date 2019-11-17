import 'package:flutter/material.dart';
import 'package:next_bus/models/transport_departure.dart';
import 'package:next_bus/models/transport_styling.dart';

class DepartureList extends StatefulWidget {

  DepartureList({Key key, this.departures}) : super(key: key);

  final List<TransportDeparture> departures;

  @override
  State<StatefulWidget> createState() {
    return new _DepartureListState();
  }
}

class _DepartureListState extends State<DepartureList> {

  @override
  Widget build(BuildContext context) {
    return _buildDepartureList(context, widget.departures);
  }

  ListTile _buildItemsForListView(BuildContext context, int index) {
    final currentDeparture = widget.departures[index];
    return ListTile(
        title: Text("${currentDeparture.name} · ${currentDeparture.direction}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        leading: _buildLeadingTile(currentDeparture),
        trailing: _buildTrailingTile(currentDeparture.nextDepartures()),
        subtitle: Text(
            "${currentDeparture.stopName} (${currentDeparture.stop.distance !=
                null ? currentDeparture.stop.humanReadableDistance() : "N/A"})",
            style: TextStyle(fontSize: 16)));
  }

  Widget _buildLeadingTile(TransportDeparture departure) {
    final transportStyling = TransportStyling.fromDeparture(departure);
    return Container(
        padding: EdgeInsets.only(right: 8.0, left: 8.0),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        color: transportStyling.backgroundColor,
        child: Text(transportStyling.shortForm,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: transportStyling.textColor)));
  }

  Widget _buildTrailingTile(List<int> departureTimes) {
    var formattedDepartureTime = departureTimes
        .map((departureTime) =>
    departureTime <= 0 ? "Now" : "$departureTime min")
        .toList();
    var departureTimeTextElements = List<Widget>();
    departureTimeTextElements.add(Text(formattedDepartureTime.first,
        textAlign: TextAlign.right,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));
    for (String departureTime in formattedDepartureTime.sublist(
        1, formattedDepartureTime.length)) {
      departureTimeTextElements.add(Text(departureTime,
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)));
    }

    return Container(
      padding: EdgeInsets.only(right: 8.0, left: 8.0, top: 4.0),
      width: 70,
      alignment: Alignment.topRight,
      child: Column(
        children: departureTimeTextElements,
      ),
    );
  }


  ListView _buildDepartureList(context, List<TransportDeparture> departures) {
    return new ListView.separated(
      physics: AlwaysScrollableScrollPhysics(),
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemCount: departures != null ? departures.length : 0,
      itemBuilder: _buildItemsForListView,
    );
  }
}