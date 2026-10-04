import 'package:flexible_packaging/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Flexible Packaging app starts', (tester) async {
    await tester.pumpWidget(const FlexiblePackagingApp());

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Find Your Next Opportunity'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(LanguageScreen), findsOneWidget);
  });
}
