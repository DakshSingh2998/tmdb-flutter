import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkChecker {
  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool? _lastStatus;

  NetworkChecker() {
    // Listen to connectivity changes
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasInternet = _mapConnectivity(results);
      if (_lastStatus != hasInternet) {
        _lastStatus = hasInternet;
        _controller.add(hasInternet);
      }
    });
  }

  /// One-time check
  Future<bool> isConnected() async {
    final results = await Connectivity().checkConnectivity();
    return _mapConnectivity(results);
  }

  /// Convert ConnectivityResult list into simple bool
  bool _mapConnectivity(List<ConnectivityResult> results) {
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }

  /// Stream of connectivity status (true = online, false = offline)
  Stream<bool> get onConnectivityChanged => _controller.stream;

  void dispose() {
    _connectivitySub?.cancel();
    _controller.close();
  }
}
