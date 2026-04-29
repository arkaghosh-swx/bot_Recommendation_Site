// lib/main.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';

// TEMP → until your screens are ready
import 'screens/chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Supabase Init ───────────────────────────────
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const SolBotApp());
}

class SolBotApp extends StatelessWidget {
  const SolBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      theme: AppTheme.dark,

      // ── Initial Screen ───────────────────────────
      home: const ChatScreen(),

      // Future routing ready
      routes: {'/chat': (_) => const ChatScreen()},
    );
  }
}
