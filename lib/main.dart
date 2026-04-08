import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';

Future<void> main() async {
  // 1. Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load environment variables from .env
  await dotenv.load(fileName: '.env');

  // 3. Validate required env vars exist
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseUrl.isEmpty) {
    throw Exception(
      'SUPABASE_URL is missing from .env file. '
      'Copy .env.example to .env and add your Supabase project URL.',
    );
  }

  if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
    throw Exception(
      'SUPABASE_ANON_KEY is missing from .env file. '
      'Copy .env.example to .env and add your Supabase anon key. '
      'WARNING: Use ONLY the anon key, NEVER the service_role key.',
    );
  }

  // 4. Initialize Supabase (single initialization, dotenv only)
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
