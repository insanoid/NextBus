import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:next_bus/models/network_error.dart';
import 'package:next_bus/models/transit_departure.dart';
import 'package:next_bus/network/api_client.dart';
import 'package:next_bus/widgets/departure_list.dart';

class DepartureView extends StatefulWidget {
  @override
  createState() => new DepartureViewState();
}

class DepartureViewState extends State<DepartureView> {
  List<TransitDeparture> allDepartures;
  Timer timer;
  GeolocationStatus geolocationStatus;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final headerTitleStyle = TextStyle(
        fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xff000000), fontFamily: "TransitBold",);
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text("NextBus", style: headerTitleStyle),
        backgroundColor: Color(0xffFBE352),
      ),
      body: new Container(
        child: new Center(
            child: new RefreshIndicator(
          backgroundColor: Color(0xffFBE352),
          color: Color(0xff000000),
          child: new DepartureList(
              departures: allDepartures, geolocationStatus: geolocationStatus),
          onRefresh: _refreshDepartures,
        )),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        Duration(seconds: 120), (Timer t) => _refreshDepartures());
    _refreshDepartures();
  }

  Future<Null> _refreshDepartures() async {
    debugPrint('Refreshing departures...');
    geolocationStatus = await Geolocator().checkGeolocationPermissionStatus();

    if (geolocationStatus == GeolocationStatus.denied) {
      _showLocationDialog();
      debugPrint("No location permission available.");
      return;
    }
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    debugPrint("Found Location: $position");

    var result = await BVGAPIClient.getDeparturesNearby(
        position.latitude, position.longitude);
    setState(() {
      if (result.runtimeType == NetworkError) {
        print(result.message);
        showErrorSnackbar();
        // @TODO: Handle network errors better.
      } else {
        this.allDepartures = result;
      }
    });
  }

  void showErrorSnackbar() {
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text("Unable to get nearby stops due to API problems."), action: SnackBarAction(
      label: 'Retry',
      onPressed: () {
        _refreshDepartures();
      },
    ),));
  }

  void _showLocationDialog() {
    // @TODO: add a link to go to settings.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Location Sharing Disabled"),
          content: new Text(
              "NextBus needs to know where you are to get stops that are near you. We do not save or share your location."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
