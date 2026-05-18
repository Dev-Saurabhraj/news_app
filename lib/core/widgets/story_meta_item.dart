import 'package:flutter/material.dart';

class StoryMetaItem extends StatelessWidget {
  const StoryMetaItem({
    required this.icon,
    required this.label,
    super.key,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = compact
        ? Theme.of(context).textTheme.bodySmall
        : Theme.of(context).textTheme.labelLarge;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: compact ? 15 : 16, color: colors.onSurfaceVariant),
        const SizedBox(width: 5),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
