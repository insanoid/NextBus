import 'package:flutter/material.dart';
import 'package:next_bus/apiclient.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BVGAPIClientInstance.getStops(52.46533, 13.2801013);
    BVGAPIClientInstance.getDeparturesForStop("900000051303");
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Flutter'),
        ),
        body: Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}

