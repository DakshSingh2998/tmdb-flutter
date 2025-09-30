import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:tmdb/screens/dashboard/dashboard.dart';

import 'core/extension/color/color_extension.dart';
import 'screens/dashboard/models/movie_response.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(MovieResponseAdapter());
  Hive.registerAdapter(MovieAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: const DashboardView(),
    );
  }
}
