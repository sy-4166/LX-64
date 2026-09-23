import 'package:flutter_test/flutter_test.dart';

import 'package:lx_64/app/app.dart';

void main() {
  testWidgets('LX-64 app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const LX64App());

    expect(find.text('LX-64'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });
}
