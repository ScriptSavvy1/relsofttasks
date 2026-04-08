import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';

Future<void> main() async {
  // 1. Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Resolve Supabase credentials
  //    Priority: compile-time --dart-define > .env file
  String? supabaseUrl;
  String? supabaseAnonKey;

  // Check compile-time defines first (used for web/Vercel deployment)
  const defineUrl = String.fromEnvironment('SUPABASE_URL');
  const defineKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (defineUrl.isNotEmpty && defineKey.isNotEmpty) {
    supabaseUrl = defineUrl;
    supabaseAnonKey = defineKey;
  } else {
    // Fall back to .env file (used for local/mobile development)
    try {
      await dotenv.load(fileName: '.env');
      supabaseUrl = dotenv.env['SUPABASE_URL'];
      supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Could not load .env file: $e');
      }
    }
  }

  // 3. Validate required env vars exist
  if (supabaseUrl == null || supabaseUrl.isEmpty) {
    throw Exception(
      'SUPABASE_URL is missing. '
      'For local dev: copy .env.example to .env and add your Supabase project URL. '
      'For web deploy: pass --dart-define=SUPABASE_URL=your_url',
    );
  }

  if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
    throw Exception(
      'SUPABASE_ANON_KEY is missing. '
      'For local dev: copy .env.example to .env and add your Supabase anon key. '
      'For web deploy: pass --dart-define=SUPABASE_ANON_KEY=your_key',
    );
  }

  // 4. Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // 5. Configure Google Fonts
  GoogleFonts.config.allowRuntimeFetching = true;

  // 6. Run the app
  runApp(
    const ProviderScope(
      child: RelsoftTeamFlowApp(),
    ),
  );
}
