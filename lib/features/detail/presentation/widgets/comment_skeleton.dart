import 'package:flutter/material.dart';

import '../../../../core/widgets/shimmer_box.dart';

class CommentSkeleton extends StatelessWidget {
  const CommentSkeleton({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: compact ? 18 : 0, bottom: 14),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 88, height: 16),
              SizedBox(width: 10),
              ShimmerBox(width: 54, height: 16),
            ],
          ),
          SizedBox(height: 10),
          ShimmerBox(width: double.infinity, height: 15),
          SizedBox(height: 7),
          ShimmerBox(width: 250, height: 15),
        ],
      ),
    );
  }
}
