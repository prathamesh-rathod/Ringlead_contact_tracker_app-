import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/app_shell.dart';
import 'screens/login_screen.dart';
import 'services/auth_repository.dart';
import 'services/reminder_service.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Light status bar icons on the light canvas, and a transparent system bar so
  // the header reads as part of the page.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  // Set up local notifications for callback reminders (best-effort).
  ReminderService.instance.init();
  runApp(const RingleadApp());
}

class RingleadApp extends StatelessWidget {
  const RingleadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ringlead',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      builder: (context, child) {
        // Keep text size sane even when the phone is set to a huge font scale.
        final scale = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.25);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scale),
          child: child!,
        );
      },
      home: const _SessionGate(),
    );
  }
}

/// Restores any cached session before deciding whether to show the login
/// screen or drop straight into the app.
class _SessionGate extends StatefulWidget {
  const _SessionGate();

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  @override
  void initState() {
    super.initState();
    AuthRepository.instance.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthRepository.instance,
      builder: (context, _) {
        switch (AuthRepository.instance.status) {
          case AuthStatus.initializing:
            return const _SplashScreen();
          case AuthStatus.signedIn:
            return const AppShell();
          case AuthStatus.signedOut:
            return const LoginScreen();
        }
      },
    );
  }
}

/// Brand mark + spinner while the cached session is restored.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppShadows.tinted(AppColors.blue),
              ),
              child: const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 18),
            const Text('Ringlead', style: AppText.h1),
            const SizedBox(height: 22),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
