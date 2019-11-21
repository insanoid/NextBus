import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';
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
  bool isLoading;

  Widget get _loadingView {
    return new Center(
      child: new CircularProgressIndicator(
          backgroundColor: Color(0xffFBE352),
          valueColor: AlwaysStoppedAnimation(Color(0xff000000))),
    );
  }

  Widget get _container {
    return new Container(
      child: new Center(
          child: new RefreshIndicator(
        backgroundColor: Color(0xffFBE352),
        color: Color(0xff000000),
        child: new DepartureList(
            departures: allDepartures, geolocationStatus: geolocationStatus),
        onRefresh: () => _refreshDepartures(true),
      )),
    );
  }

  Widget get _pageToDisplay {
    if (isLoading) {
      return _loadingView;
    } else {
      return _container;
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerTitleStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xff000000),
      fontFamily: "TransitBold",
    );
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text("NextBus", style: headerTitleStyle),
        backgroundColor: Color(0xffFBE352),
      ),
      body: _pageToDisplay,
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshDepartures(false);
  }

  void restartTimer() {
    killTimer();
    timer = Timer.periodic(
        Duration(seconds: 60), (Timer t) => _refreshDepartures(false));
    debugPrint("Timer Restarted");
  }

  void killTimer() {
    if (timer != null) {
      debugPrint("Timer Killed");
      timer.cancel();
      timer = null;
    }
  }

  Future<Null> _refreshDepartures(bool isPullToRefresh) async {
    if (!isPullToRefresh) {
      setState(() {
        // If it's not pull to refresh we need to show the refresh in the UI.
        isLoading = true;
      });
    }
    debugPrint('Refreshing departures...');
    // This callback fails if the permission dialog is presented and the user selects denied.
    // It throws an exception, when that happens we just show the warning and stop.
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high).catchError(_handleLocationFailure);
    if (position == null) {
      // the error block will handle fixing UI.
      return;
    }
    geolocationStatus = GeolocationStatus.granted;
    debugPrint("Found Location: $position");
    // Restart timer here; If the user manually refreshed the list we do not need to trigger it again for the refresh duration.
    restartTimer();
    var response = await BVGAPIClient.getDeparturesNearby(position.latitude, position.longitude);
    _handleNewDepartureList(response);
  }


  // When we have a new list of departures/error trigger this function to update the UI.
  void _handleNewDepartureList(response) {
    setState(() {
      isLoading = false;
      if (response.runtimeType == NetworkError) {
        debugPrint(response.description());
        showErrorSnackBar();
        // @TODO: Handle network errors better.
      } else {
        this.allDepartures = response;
      }
    });
  }

  void _handleLocationFailure(Object error) {
    // We do not want to keep restarting the location check if it failed once, needs to be manually triggered.
    // Avoids spawning multiple error dialogs.
    killTimer();
    geolocationStatus = GeolocationStatus.denied;
    _showLocationPermissionErrorDialog();
    setState(() {
      isLoading = false;
      debugPrint("No location permission available.");
    });
  }

  void showErrorSnackBar() {
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text("Unable to get nearby stops due to API problems."),
      action: SnackBarAction(
        label: 'Retry',
        onPressed: () {
          _refreshDepartures(false);
        },
      ),
    ));
  }

  void _showLocationPermissionErrorDialog() {
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
            new FlatButton(
              child: new Text("Open Permissions"),
              onPressed: () {
                LocationPermissions().openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
