import 'package:flutter_test/flutter_test.dart';
import 'package:vlog_date/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VlogDateApp());
    expect(find.byType(VlogDateApp), findsOneWidget);
  });
}
