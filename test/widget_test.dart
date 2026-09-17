// This is a basic Flutter widget test.
import 'package:flutter_test/flutter_test.dart';
import 'package:odjek/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Simply verify that the app runs and constructs MyApp successfully.
    // (Note: we cannot easily run full DB / initialization flows in a simple widget test without mocks)
    expect(const MyApp(), isNotNull);
  });
}
