import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend/main.dart';
import 'package:frontend/services/auth_service.dart';

void main() {
  testWidgets('App landing screen shows Neo Wallet brand smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService()),
        ],
        child: const RecipeWalletApp(),
      ),
    );

    // Verify that our brand heading is displayed.
    expect(find.text('NEO WALLET'), findsOneWidget);
  });
}
