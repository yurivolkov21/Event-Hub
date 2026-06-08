import 'package:flutter_test/flutter_test.dart';

import 'package:event_hub/main.dart';

void main() {
  testWidgets('renders EventHub home', (WidgetTester tester) async {
    await tester.pumpWidget(const EventHubApp());

    expect(find.text('EventHub'), findsWidgets);
  });
}
