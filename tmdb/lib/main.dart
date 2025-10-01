import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'core/extension/color/color_extension.dart';
import 'screens/dashboard/models/movie_response.dart';
import 'screens/dashboardContainer/dashboard_container.dart';
import 'screens/movieDetail/movie_detail_deeplink.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
const kWindowsScheme = 'tmdb';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(MovieResponseAdapter());
  Hive.registerAdapter(MovieAdapter());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    // Handle links
    _linkSubscription = AppLinks().uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) {
    if (uri.path == "/movie" && uri.queryParameters.containsKey("movieId")) {
      final movieId = int.tryParse(uri.queryParameters["movieId"]!);
      if (movieId != null) {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => MovieDetailDeeplink(movieId: movieId),
          ),
        );
      }
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorObservers: [routeObserver],
      navigatorKey: _navigatorKey,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: myMainColor,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: myMainColor[500]!, // 90% opaque
          onPrimary: Colors.white,
          secondary: myMainColor[700]!, // More blended blue
          onSecondary: Colors.white,
          error: const Color.fromARGB(255, 175, 6, 6),
          onError: Colors.white,
          surface: myMainColor[50]!, // 94% white, semi-transparent effect
          onSurface: const Color(0xFF1E1E1E), // Soft black
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: myMainColor[500]!,
            foregroundColor: Colors.white,
            shadowColor: const Color.fromARGB(100, 0, 0, 0), // softer shadow
            elevation: 3,
          ),
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(
            220,
            255,
            255,
            255,
          ), // white-ish with transparency
          foregroundColor: myMainColor[900],
          elevation: 0,
          surfaceTintColor: Colors.transparent, // removes M3 blur
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color.fromARGB(
            240,
            255,
            255,
            255,
          ), // semi-transparent white
          selectedItemColor: myMainColor[500]!,
          unselectedItemColor: myMainColor[900]!,
          elevation: 8,
          selectedIconTheme: const IconThemeData(size: 26),
          unselectedIconTheme: const IconThemeData(size: 24),
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      home: const DashboardContainerView(),
    );
  }
}
