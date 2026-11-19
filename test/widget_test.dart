
import 'package:flutter_test/flutter_test.dart';
import 'package:technewz_360/main.dart';

void main() {
  testWidgets('TechNewz 360 app loads successfully',
      (WidgetTester tester) async {

    await tester.pumpWidget(const TechNewzApp());

    // Check whether the app title is visible.
    expect(find.text('TECHNEWZ 360'), findsOneWidget);

    // Check whether the home screen is visible.
    expect(find.text('Explore the future.'), findsOneWidget);
  });
}
