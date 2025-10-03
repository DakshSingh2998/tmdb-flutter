import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class MovieShimmer extends StatelessWidget {
  final bool isGrid;

  const MovieShimmer({super.key, this.isGrid = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: isGrid ? _buildGridShimmer() : _buildListShimmer(),
    );
  }

  Widget _buildGridShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Poster shimmer with same aspect ratio as MovieCard
        AspectRatio(
          aspectRatio: 2 / 2.8,
          child: Shimmer(
            duration: const Duration(milliseconds: 1500),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Title shimmer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Shimmer(
            duration: const Duration(milliseconds: 1500),
            child: Container(
              height: 14,
              width: double.infinity,
              color: Colors.grey.shade300,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildListShimmer() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Poster shimmer with aspect ratio
          AspectRatio(
            aspectRatio: 2 / 2.8,
            child: Shimmer(
              duration: const Duration(milliseconds: 1500),
              child: Container(
                width: 60, // width controlled by ListTile leading
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Text shimmer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer(
                  duration: const Duration(milliseconds: 1500),
                  child: Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer(
                  duration: const Duration(milliseconds: 1500),
                  child: Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer(
                  duration: const Duration(milliseconds: 1500),
                  child: Container(
                    height: 14,
                    width: 150,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
