import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'services/auth_service.dart';
import 'services/location_service.dart';
import 'services/request_service.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';

const Color _brandColor = Color(0xFF0D47A1);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _brandColor,
      primary: _brandColor,
    );

    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<RequestService>(create: (_) => RequestService()),
        Provider<LocationService>(create: (_) => LocationService()),
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(context.read<AuthService>()),
        ),
      ],
      child: MaterialApp(
        title: 'UTFPR Solicitações',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: colorScheme,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF4F6FA),
          appBarTheme: AppBarTheme(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE6E9F0)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD6DBE6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD6DBE6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: colorScheme.primary,
              side: const BorderSide(color: Color(0xFFD6DBE6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (!auth.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return auth.isAuthenticated ? const HomeView() : const LoginView();
  }
}
