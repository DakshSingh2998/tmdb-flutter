import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkChecker {
  final _controller = StreamController<bool>.broadcast();
  bool? _lastStatus;
  Timer? _timer;

  NetworkChecker() {
    // Start periodic connectivity checks (e.g., every 2 seconds)
    _timer = Timer.periodic(Duration(seconds: 2), (_) async {
      final currentStatus = await isConnected();
      if (_lastStatus != currentStatus) {
        _lastStatus = currentStatus;
        _controller.add(currentStatus);
      }
    });
  }

  /// One-time check
  Future<bool> isConnected() async {
    final bool isConnected = await InternetConnection().hasInternetAccess;
    return isConnected;
  }

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged => _controller.stream;

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
