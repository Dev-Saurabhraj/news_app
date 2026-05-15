import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StaggeredListItem extends StatelessWidget {
  const StaggeredListItem({
    required this.index,
    required this.child,
    super.key,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: (index * 42).ms)
        .fadeIn(duration: 280.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.04,
          end: 0,
          duration: 320.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
