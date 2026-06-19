import 'package:flutter_test/flutter_test.dart';
import 'package:cleanoov_app/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CleanoovApp());
    expect(find.text('CLEANOOV'), findsNothing);
  });
}
