import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lg_task2_demo/providers/settings_provider.dart';
import 'package:lg_task2_demo/providers/theme_provider.dart';
import 'package:lg_task2_demo/screens/splash_screen.dart';
import 'package:lg_task2_demo/screens/main_screen.dart';
import 'package:lg_task2_demo/screens/connection_screen.dart';
import 'package:lg_task2_demo/screens/settings_screen.dart';
import 'package:lg_task2_demo/screens/help_screen.dart';

import 'package:lg_task2_demo/services/lg_service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LGService()),
      ],
      child: const LGStarterApp(),
    ),
  );
}

class LGStarterApp extends StatelessWidget {
  const LGStarterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'DEMO LG Controller',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/connection': (context) => const ConnectionScreen(),
        '/main': (context) => const MainScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/help': (context) => const HelpScreen(),

      },
    );
  }
}
