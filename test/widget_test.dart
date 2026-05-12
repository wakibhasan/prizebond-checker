import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Placeholder smoke test', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('hi'))),
    );
    expect(find.text('hi'), findsOneWidget);
  });
}
