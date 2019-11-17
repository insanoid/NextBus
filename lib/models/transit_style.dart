import 'dart:ui';

import 'package:next_bus/models/transit_departure.dart';
import 'package:next_bus/models/transit_type.dart';

// A class to handle themes of different transit mode icons.
class TransitStyle {
  // Short form that is represented in icons and on boards.
  final shortForm;

  // Background color for the transit symbol.
  final Color backgroundColor;

  // Text color that can be used on top of the transit symbol background color.
  final Color textColor;

  TransitStyle({this.shortForm, this.backgroundColor, this.textColor});

  factory TransitStyle.fromDeparture(TransitDeparture departure) {
    var transitShortForm;
    Color transitColor;
    Color transitShortFormColor = Color(0xffffffff);
    switch (departure.transitType) {
      case TransitType.bus:
        transitShortForm = "B";
        transitColor = Color(0xffEDCF1B);
        transitShortFormColor = Color(0xff000000);
        break;
      case TransitType.subway:
        transitShortForm = "U";
        transitColor = Color(0xff226399);

        break;
      case TransitType.suburban:
        transitShortForm = "S";
        transitColor = Color(0xff22B136);
        break;
      case TransitType.tram:
        transitShortForm = "M";
        transitColor = Color(0xffEDCF1B);
        break;
      case TransitType.express:
        transitShortForm = "E";
        transitColor = Color(0xffDB3738);
        break;
      case TransitType.ferry:
        transitShortForm = "F";
        transitColor = Color(0xff3483C3);
        break;
      case TransitType.regional:
      default:
        transitShortForm = "B";
        transitColor = Color(0xffDB3738);
        break;
    }
    return TransitStyle(
        shortForm: transitShortForm,
        backgroundColor: transitColor,
        textColor: transitShortFormColor);
  }
}
