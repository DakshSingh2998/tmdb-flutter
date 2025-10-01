import 'package:flutter/material.dart';

class SearchMovieView extends StatefulWidget {
  const SearchMovieView({Key? key}) : super(key: key);

  @override
  State<SearchMovieView> createState() => _SearchMovieViewState();
}

class _SearchMovieViewState extends State<SearchMovieView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Movie')),
      body: const Center(child: Text('Search Movie View')),
    );
  }
}
