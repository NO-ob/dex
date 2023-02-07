import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final httpClientProvider =
    Provider<HttpClient>((ref) => throw UnimplementedError());

/// Enum used to decide which request function to call
enum RequestType {
  jsonGet,
}

/// Data class for HTTP requests it has a [type] and [url]
/// The callback fucntion will be called once the request completes
class Request {
  RequestType type;
  String url;
  Completer completer;
  Request({required this.type, required this.url, required this.completer});
}

class HttpClientException implements Exception {
  String message;
  HttpClientException(this.message);
}

/// HttpClient class, it uses a queue to avoid rate limiting
class HttpClient {
  Queue<Request> requests = Queue();
  Dio dio = Dio();
  bool requestRunning = false;
  Duration timeOut = const Duration(milliseconds: 500);
  Duration delay = const Duration(milliseconds: 20);
  int retryCount = 0;

  HttpClient() {
    print("Http client created");
  }

  void queueRequest(Request request) {
    requests.add(request);
    _doRequest();
  }

  void _doRequest() async {
    if (requestRunning || requests.isEmpty) {
      return;
    }
    requestRunning = true;
    Request request = requests.removeFirst();
    switch (request.type) {
      case RequestType.jsonGet:
        await _getJson(request);
        break;
    }

    requestRunning = false;
    retryCount = 0;
    if (requests.isNotEmpty) {
      _doRequest();
    }
  }

  Future<void> _getJson(Request request) async {
    await Future.delayed(delay);
    try {
      var response = await Dio().get(request.url);

      if (response.statusCode == 200) {
        request.completer.complete(response.data);
        return;
      }

      if (response.statusCode == 404) {
        request.completer
            .completeError(HttpClientException("404: ${request.url}"));
        return;
      }

      if (retryCount < 3) {
        retryCount++;
        await Future.delayed(timeOut);
        return _getJson(request);
      }

      request.completer.completeError(HttpClientException(
          "Non 200 status code: ${response.statusCode}, ${response.statusMessage}"));
    } catch (e) {
      request.completer.completeError(
          HttpClientException("Exception thrown during get request"));
    }
  }
}
