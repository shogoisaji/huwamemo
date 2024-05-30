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
      scaffoldBackgroundColor: Colors.grey,
      fontFamily: 'InterTight',
      useMaterial3: true,
    ),
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
