import 'package:flutter_test/flutter_test.dart';
import 'package:markflow/app/app.dart';

void main() {
  testWidgets('MarkFlow app should render', (WidgetTester tester) async {
    await tester.pumpWidget(const MarkFlowApp());
    expect(find.text('File'), findsOneWidget);
  });
}
