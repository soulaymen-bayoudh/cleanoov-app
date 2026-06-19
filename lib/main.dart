import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les données de locale française (fix LocaleDataException)
  await initializeDateFormatting('fr', null);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialiser Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase non configuré — mode local (remplacez firebase_options.dart)
    debugPrint('Firebase non initialisé: $e');
  }

  runApp(const CleanoovApp());
}

class CleanoovApp extends StatelessWidget {
  const CleanoovApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cleanoov',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const _AuthGate(),
    );
  }
}

// Vérifie si un technicien est déjà connecté au lancement
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Déjà connecté → récupérer le profil et aller à HomeScreen
        if (snap.hasData && snap.data != null) {
          return FutureBuilder<TechnicienProfile?>(
            future: AuthService.getCurrentProfile(),
            builder: (ctx2, profSnap) {
              if (profSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final profile = profSnap.data;
              if (profile == null) return const LoginScreen();
              return HomeScreen(
                technicienName: profile.nom,
                technicienTel: profile.telephone,
              );
            },
          );
        }

        // Non connecté → écran de login
        return const LoginScreen();
      },
    );
  }
}
