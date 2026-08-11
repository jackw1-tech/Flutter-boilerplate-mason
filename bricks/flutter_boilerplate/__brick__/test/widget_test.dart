// Smoke test for the generated app.
//
// It boots the whole app — DependencyInjector, AppTheme and the auto_route
// router — and checks that the initial route renders and that the local state
// demo on HomePage reacts to input. Layer-specific tests (mappers, repositories,
// blocs) belong in test/ mirroring the lib/ structure; see AGENTS.md §12.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:{{project_name.snakeCase()}}/main.dart';

void main() {
  testWidgets('App boots on HomePage and the counter demo updates', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const {{project_name.pascalCase()}}App());
    await tester.pumpAndSettle();

    // The initial route resolved through AppRouter.
    expect(find.text('Pine Architecture'), findsOneWidget);
    expect(find.text('Counter: 0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('Counter: 1'), findsOneWidget);
  });
}
