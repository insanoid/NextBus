// Class to store responses from multiple requests in a way we can detect partial completion.
import 'network_error.dart';

class MultipleRequestResponse {
  ResponseStatus status;
  dynamic response;
  NetworkError error;

  MultipleRequestResponse({this.status, this.response, this.error});
}
