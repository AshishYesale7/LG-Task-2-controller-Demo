import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_client/providers/settings_provider.dart';
import 'package:flutter_client/providers/theme_provider.dart';
import 'package:flutter_client/screens/splash_screen.dart';
import 'package:flutter_client/screens/main_screen.dart';
import 'package:flutter_client/screens/connection_screen.dart';
import 'package:flutter_client/screens/settings_screen.dart';
import 'package:flutter_client/screens/help_screen.dart';
import 'package:flutter_client/screens/workflow_flow_screen.dart';
import 'package:flutter_client/services/lg_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'LG Starter Kit',
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
        '/workflow': (context) => const WorkflowFlowScreen(),
      },
    );
  }
}
