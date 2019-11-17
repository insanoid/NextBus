
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:next_bus/models/network_error.dart';
import 'package:next_bus/models/transport_departure.dart';
import 'package:next_bus/network/api_client.dart';
import 'package:next_bus/widgets/departure_list.dart';

class DepartureView extends StatefulWidget {
  @override createState() => new DepartureViewState();
}

class DepartureViewState extends State<DepartureView> {
  List<TransportDeparture> allDepartures;
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 120), (Timer t) => _refreshDepartures());
    _refreshDepartures();
  }

  Future<void> _refreshDepartures() async
  {
    print('refreshing departures...');

    BVGAPIClient.getRelevantDepartures(52.46533, 13.2801013).then((result) {
      setState(() {
        print("------------>>>>>> $result");
        if (result.runtimeType == NetworkError) {
          print(result.message);
          // Handle network errors better?
        } else {
          this.allDepartures = result;
        }
      });
    });
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
              child: new DepartureList(departures: allDepartures,),
              onRefresh: _refreshDepartures,
            )
        ),
      ),
    );
  }
}