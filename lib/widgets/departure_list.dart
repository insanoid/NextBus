import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:next_bus/models/transit_departure.dart';
import 'package:next_bus/models/transit_stop.dart';
import 'package:next_bus/models/transit_style.dart';
import 'package:url_launcher/url_launcher.dart';

// A UI to show the list of departures with pull-to-refresh feature.
class DepartureList extends StatefulWidget {
  DepartureList({Key key, this.departures, this.geolocationStatus})
      : super(key: key);

  final List<TransitDeparture> departures;
  GeolocationStatus geolocationStatus;

  @override
  State<StatefulWidget> createState() {
    return new _DepartureListState();
  }
}

// State to store information regarding departure list.
class _DepartureListState extends State<DepartureList> {
  @override
  Widget build(BuildContext context) {
    return _buildDepartureList(
        context, widget.departures, widget.geolocationStatus);
  }

  ListTile _buildItemsForEmptyListView(BuildContext context, int index) {
    return ListTile(
      contentPadding: EdgeInsets.only(
          top: index == 0 ? 16.0 : 2.0, bottom: 2.0, right: 4.0, left: 4.0),
      title: Text("↻ Pull to Refresh",
          softWrap: false,
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0x66444444))),
      subtitle: Text(
          widget.geolocationStatus != null && widget.geolocationStatus != GeolocationStatus.granted
              ? "Enable Location Permissions for NextBus to continue."
              : "",
          softWrap: false,
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0x66444444))),
    );
  }

  ListTile _buildItemsForListView(BuildContext context, int index) {
    final currentDeparture = widget.departures[index];
    final departureTitle =
        "${currentDeparture.name} · ${currentDeparture.direction}";
    final distanceText = currentDeparture.stop.distance != null
        ? "(${currentDeparture.stop.formattedDistanceString()})"
        : "";
    final subTitle = "${currentDeparture.stopName} $distanceText";
    return ListTile(
        contentPadding: EdgeInsets.only(
            top: index == 0 ? 16.0 : 2.0, bottom: 2.0, right: 4.0, left: 4.0),
        title: Text(departureTitle,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        leading: _buildTransitIconTile(currentDeparture),
        trailing: _buildTransitDepartureTimeTile(currentDeparture),
        subtitle: Text(subTitle, style: TextStyle(fontSize: 16)),
        onTap: () => _openMap(currentDeparture.stop),);
  }

  // BVG themed tile of the public transport type.
  Widget _buildTransitIconTile(TransitDeparture departure) {
    final transitStyle = TransitStyle.fromDeparture(departure);
    return Container(
        padding: EdgeInsets.all(4.0),
        margin: EdgeInsets.only(left: 2.0, right: 2.0),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        color: transitStyle.backgroundColor,
        child: Text(transitStyle.shortForm,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "TransitBold",
                color: transitStyle.textColor)));
  }

  // Transit departure time with the first time being bigger than other 2 (max 3).
  Widget _buildTransitDepartureTimeTile(TransitDeparture departure) {
    List<int> departureTimes = departure.nextDepartures();
    var formattedDepartureTime = List();
    for (int time in departureTimes) {
      // If time is less than zero, we don't even consider.
      if (time < 0) {
        continue;
      }
      time == 0
          ? formattedDepartureTime.add("Now")
          : formattedDepartureTime.add("$time min");
    }

    var departureTimeTextElements = List<Widget>();
    // First
    if(formattedDepartureTime.length > 0) {
      departureTimeTextElements.add(Text(formattedDepartureTime.first,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));
      for (String departureTime
      in formattedDepartureTime.sublist(1, formattedDepartureTime.length)) {
        departureTimeTextElements.add(Text(departureTime,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)));
      }
    }

    return Container(
      padding: EdgeInsets.only(right: 8.0, left: 0.0, top: 0.0),
      margin: EdgeInsets.all(0),
      width: 70,
      alignment: Alignment.topRight,
      child: Column(
        children: departureTimeTextElements,
      ),
    );
  }

  ListView _buildDepartureList(context, List<TransitDeparture> departures,
      GeolocationStatus geolocationStatus) {
    // We need it to be null to make sure empty view is being shown when nothing is there.
    departures = departures == null || departures.length == 0 ? null : departures;
    return new ListView.separated(
      physics: AlwaysScrollableScrollPhysics(),
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemCount: departures != null ? departures.length : 1,
      itemBuilder: departures != null
          ? _buildItemsForListView
          : _buildItemsForEmptyListView,
    );
  }

  _openMap(TransitStop stop) async {
    // Android
    var url = "geo:${stop.latitude},${stop.longitude}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // If it's iOS then open apple maps.
      var url = "http://maps.apple.com/?ll=${stop.latitude},${stop.longitude}";
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw "Could not launch $url";
      }
    }
  }

}
