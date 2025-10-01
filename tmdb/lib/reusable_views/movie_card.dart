import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class MovieCard extends StatelessWidget {
  final String title;
  final String? overview;
  final String? posterPath;
  final VoidCallback? onTap;
  final bool isGrid; // to adapt design for grid/list

  const MovieCard({
    super.key,
    required this.title,
    this.overview,
    this.posterPath,
    this.onTap,
    this.isGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: isGrid ? _buildGridCard() : _buildListCard(),
      ),
    );
  }

  Widget _buildListCard() {
    return ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildPoster(width: 60, height: 90),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: overview != null
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                overview!,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  Widget _buildGridCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: _buildPoster(height: 260, width: double.infinity),
        ),
        Spacer(),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Spacer(),
      ],
    );
  }

  Widget _buildPoster({double? width, double? height}) {
    if (posterPath == null) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        child: const Icon(Icons.movie, size: 40),
      );
    }

    return CachedNetworkImage(
      imageUrl: "https://image.tmdb.org/t/p/w300$posterPath",
      width: width,
      height: height,
      fit: BoxFit.cover,
      progressIndicatorBuilder: (context, url, downloadProgress) => Shimmer(
        duration: Duration(milliseconds: 1500),
        child: Container(
          width: width,
          height: height,
          color: Colors.grey.shade300,
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error, size: 40),
    );
  }
}
