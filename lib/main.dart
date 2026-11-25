import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';

import 'package:login_rive_animation_26_3_tsw/screens/login_screen.dart';
import 'package:login_rive_animation_26_3_tsw/theme/app_theme.dart';
import 'package:login_rive_animation_26_3_tsw/theme/theme_controller.dart';

Future<void> main() async {
  // Encender el puente nativo antes de usar Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase usando las credenciales de firebase_options.dart
  await Firebase.initializeApp(options: firebaseOptions);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Se reconstruye cada vez que el usuario cambia entre modo día y noche
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) => MaterialApp(
        title: 'Iniciar sesión',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        // Textos del sistema (Atrás, Copiar, Pegar...) en español
        locale: const Locale('es', 'MX'),
        supportedLocales: const [Locale('es', 'MX'), Locale('es')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const LoginScreen(),
      ),
    );
  }
}
