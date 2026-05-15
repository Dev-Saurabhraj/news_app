import 'package:flutter/material.dart';

import '../../../../core/widgets/shimmer_box.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: 7,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShimmerBox(width: 84, height: 24, borderRadius: 20),
                    Spacer(),
                    ShimmerBox(width: 42, height: 24, borderRadius: 20),
                  ],
                ),
                SizedBox(height: 16),
                ShimmerBox(width: double.infinity, height: 20),
                SizedBox(height: 9),
                ShimmerBox(width: 260, height: 20),
                SizedBox(height: 18),
                Row(
                  children: [
                    ShimmerBox(width: 70, height: 18),
                    SizedBox(width: 10),
                    ShimmerBox(width: 86, height: 18),
                    SizedBox(width: 10),
                    ShimmerBox(width: 62, height: 18),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
