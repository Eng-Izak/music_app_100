import 'package:flutter_test/flutter_test.dart';
import 'package:music_app_100/core/routing/app_router.dart';
import 'package:music_app_100/app/music_app.dart';
import 'package:music_app_100/core/dependency_injection/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await setupInjection();
    await tester.pumpWidget(MusicApp(appRouter: AppRouter()));
  });
}
