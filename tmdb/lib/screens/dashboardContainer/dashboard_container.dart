import 'package:flutter/material.dart';
import '../dashboard/dashboard.dart';
import '../nowPlaying/now_playing.dart';
import '../savedMoviesOffline/saved_movies.dart';
import '../searchMovie/search_movie.dart';

class DashboardContainerView extends StatefulWidget {
  const DashboardContainerView({super.key});

  @override
  State<DashboardContainerView> createState() => _DashboardContainerViewState();
}

class _DashboardContainerViewState extends State<DashboardContainerView> {
  late List<Widget?> screenCache;
  int tabIndex = 0;
  final icons = [Icons.home, Icons.play_arrow, Icons.search, Icons.bookmark];

  @override
  void initState() {
    super.initState();
    screenCache = List<Widget?>.filled(4, null); // 3 tabs
    screenCache[0] = DashboardView(); // Load first screen by default
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: tabIndex,
          onTap: _selectedTab,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: List.generate(icons.length, (index) {
            final isSelected = index == tabIndex;
            return BottomNavigationBarItem(
              label: "",
              icon: isSelected
                  ? Container(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Icon(icons[index]),
                    )
                  : Icon(
                      icons[index],
                      color: Colors.grey, // inactive icon color
                    ),
            );
          }),
        ),
        body: IndexedStack(
          index: tabIndex,
          children: List.generate(
            screenCache.length,
            (index) => screenCache[index] ?? const SizedBox(), // Placeholder
          ),
        ),
      ),
    );
  }

  void _selectedTab(int index) {
    if (screenCache[index] == null) {
      switch (index) {
        case 2:
          screenCache[index] = const SearchMovieView();
          break;
        case 1:
          screenCache[index] = const NowPlayingView();
          break;
      }
    }
    if (index == 3) {
      screenCache[index] = SavedMovies(key: UniqueKey());
    }

    setState(() {
      tabIndex = index;
    });
  }
}
