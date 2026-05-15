import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void toggleTheme(Brightness platformBrightness) {
    final isDark =
        state == ThemeMode.dark ||
        (state == ThemeMode.system && platformBrightness == Brightness.dark);
    emit(isDark ? ThemeMode.light : ThemeMode.dark);
  }
}
