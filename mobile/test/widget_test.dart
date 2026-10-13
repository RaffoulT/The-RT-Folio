import 'package:flutter_test/flutter_test.dart';
import 'package:rt_captured_on_film/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RtCapturedOnFilmApp());
    expect(find.text('RT.CAPTURED.ON.FILM'), findsOneWidget);
  });
}
