import 'dart:ui';

import 'package:next_bus/models/transport_departure.dart';

class TransportStyling {
  final shortForm;
  final Color backgroundColor;
  final Color textColor;

  TransportStyling({this.shortForm, this.backgroundColor, this.textColor});

  factory TransportStyling.fromDeparture(TransportDeparture departure) {
    var transportShortForm;
    Color transportColor;
    Color transportShortFormColor = Color(0xffffffff);
    switch (departure.transportType) {
      case "bus":
        transportShortForm = "B";
        transportColor = Color(0xffEDCF1B);
        transportShortFormColor = Color(0xff000000);
        break;
      case "subway":
        transportShortForm = "U";
        transportColor = Color(0xff226399);

        break;
      case "suburban":
        transportShortForm = "S";
        transportColor = Color(0xff22B136);
        break;
      case "tram":
        transportShortForm = "M";
        transportColor = Color(0xffEDCF1B);
        break;
      case "express":
        transportShortForm = "E";
        transportColor = Color(0xffDB3738);
        break;
      case "ferry":
        transportShortForm = "F";
        transportColor = Color(0xff3483C3);
        break;
      case "regional":
      default:
        transportShortForm = "B";
        transportColor = Color(0xffDB3738);
        break;
    }
    return TransportStyling(
      shortForm: transportShortForm,
      backgroundColor: transportColor,
      textColor: transportShortFormColor
    );
  }
}