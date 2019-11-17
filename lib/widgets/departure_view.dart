import 'dart:async';

import 'package:flutter/material.dart';
import 'package:next_bus/models/network_error.dart';
import 'package:next_bus/models/transit_departure.dart';
import 'package:next_bus/network/api_client.dart';
import 'package:next_bus/widgets/departure_list.dart';

import 'package:geolocator/geolocator.dart';

class DepartureView extends StatefulWidget {
  @override
  createState() => new DepartureViewState();
}

class DepartureViewState extends State<DepartureView> {
  List<TransitDeparture> allDepartures;
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        Duration(seconds: 120), (Timer t) => _refreshDepartures());
    _refreshDepartures();
  }

  Future<void> _refreshDepartures() async {
    debugPrint('Refreshing departures...');

    GeolocationStatus geolocationStatus =
        await Geolocator().checkGeolocationPermissionStatus();
    if (geolocationStatus == GeolocationStatus.denied) {
      _showLocationDialog();
      debugPrint("No location permission available.");
      return;
    }
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    debugPrint("Found Location: $position");
    BVGAPIClient.getDeparturesNearby(position.latitude, position.longitude)
        .then((result) {
      setState(() {
        if (result.runtimeType == NetworkError) {
          print(result.message);
          // @TODO: Handle network errors better.
        } else {
          this.allDepartures = result;
        }
      });
    });
  }

  void _showLocationDialog() {
    // @TODO: add a link to go to settings.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Location Sharing Disabled"),
          content: new Text("NextBus needs to know where you are to get stops that are near you. We do not save or share your location."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close")
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final headerTitleStyle = TextStyle(
        fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xff000000));
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("NextBus", style: headerTitleStyle),
        backgroundColor: Color(0xffFBE352),
      ),
      body: new Container(
        child: new Center(
            child: new RefreshIndicator(
          child: new DepartureList(
            departures: allDepartures,
          ),
          onRefresh: _refreshDepartures,
        )),
      ),
    );
  }
}
