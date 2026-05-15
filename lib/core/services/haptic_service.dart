import 'package:flutter/services.dart';

class HapticService {
  const HapticService();

  Future<void> lightImpact() => HapticFeedback.lightImpact();
  Future<void> selection() => HapticFeedback.selectionClick();
}
