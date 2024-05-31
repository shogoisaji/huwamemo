import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huwamemo/repository/shared_preferences/shared_preferences_repository.dart';
import 'package:huwamemo/ui/home_screen/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  late final SharedPreferences sharedPreferences;
  WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
  sharedPreferences = await SharedPreferences.getInstance();

  /// 画面の向きを固定.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white, // ステータスバーの背景色
    statusBarIconBrightness: Brightness.dark, // アイコンの明るさ（darkまたはlight）
  ));
  const app = MyApp();
  final scope = ProviderScope(overrides: [
    sharedPreferencesRepositoryProvider
        .overrideWithValue(SharedPreferencesRepository(sharedPreferences)),
  ], child: app);
  runApp(MaterialApp(
    home: scope,
    theme: ThemeData(
        scaffoldBackgroundColor: Colors.blueGrey,
        fontFamily: 'MPlusRounded1c',
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            elevation: WidgetStateProperty.all(1.5),
          ),
        ),
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.blueGrey.shade800,
          onPrimary: const Color.fromARGB(255, 196, 202, 203),
          secondary: const Color(0xFFFF9800),
          onSecondary: Colors.brown,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.blueGrey.shade200,
          onSurface: Colors.blueGrey.shade900,
        )),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
