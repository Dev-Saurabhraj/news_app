import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/theme/app_theme.dart';

void main() {
  testWidgets('applies Signal HN theme shell', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: Text('Signal HN')),
      ),
    );

    expect(find.text('Signal HN'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Signal HN'))).colorScheme.primary,
      isNotNull,
    );
  });
}
