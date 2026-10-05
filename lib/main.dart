import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'config/env.dart';
import 'data/mock_repository.dart';
import 'data/repository.dart';
import 'data/supabase_repository.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Com as chaves do Supabase (--dart-define) o app usa o banco de verdade;
  // sem elas, ou se a conexão falhar, roda com dados de exemplo.
  GraoRepository repository = MockRepository();
  if (Env.hasSupabase) {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );
      repository = SupabaseRepository();
    } catch (e) {
      debugPrint('Supabase não iniciou, seguindo com dados de exemplo: $e');
    }
  }

  runApp(GraoApp(state: AppState(repository: repository, prefs: prefs)));
}

class GraoApp extends StatelessWidget {
  const GraoApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Grão',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SplashScreen(),
      ),
    );
  }
}
