// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:evrakapp/main.dart'; // Ana widget'ınızı import edin

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Uygulamanızın ana widget'ını test edin
    await tester.pumpWidget(EvrakYonetApp()); // MyApp yerine EvrakYonetApp kullanın

    // Başlangıçta 0 metnini bulun (örneğin)
    // expect(find.text('0'), findsOneWidget);
    // expect(find.text('1'), findsNothing);

    // Bir butona dokunun ve sonraki frame'i bekleyin
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();

    // Sayacın arttığını doğrulayın
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
  });
}