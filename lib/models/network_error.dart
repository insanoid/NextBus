import 'package:dio/dio.dart';

// A class to store network errors in a more accessible manner.
class NetworkError {
  dynamic message;
  int headerCode;
  Response response;
  Uri requestURL;

  NetworkError({this.message, this.headerCode, this.response, this.requestURL});

  factory NetworkError.fromResponse(Response response) {
    if(response == null) {
      return NetworkError(message: "", headerCode: 400, requestURL: null, response: null);
    }
    return NetworkError(
        message: response.data,
        headerCode: response.statusCode,
        requestURL: response.request.uri,
        response: response);
  }

  // Description string printer for easy debugging.
  String description() {
    return "$headerCode - $requestURL - $message";
  }
}

// Enum to indicate responses when combined together.
enum ResponseStatus { OK, OKWithSomeFailures, Failure }
