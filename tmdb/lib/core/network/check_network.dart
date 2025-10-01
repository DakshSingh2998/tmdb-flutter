import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkChecker {
  Future<bool> isConnected() async {
    final bool isConnected = await InternetConnection().hasInternetAccess;
    return isConnected;
  }
}
