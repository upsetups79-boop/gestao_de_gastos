
  import 'package:flutter/material.dart';
  import 'screens/home_screen.dart';                                                                                      import 'screens/lock_screen.dart';
                                                                                                                          void main() {
    runApp(const MyApp());
  }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Gestor Financeiro Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.system,
        home: const AuthGate(),
      );
    }
  }

  class AuthGate extends StatefulWidget {
    const AuthGate({super.key});

    @override
    State<AuthGate> createState() => _AuthGateState();
  }

  class _AuthGateState extends State<AuthGate> {
    bool _unlocked = false;

    @override
    Widget build(BuildContext context) {
      if (_unlocked) return const HomeScreen();
      return LockScreen(onUnlocked: () => setState(() => _unlocked = true));
    }
  }
