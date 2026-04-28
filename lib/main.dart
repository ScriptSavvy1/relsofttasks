import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handlers — catch unhandled Flutter & platform errors.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('Unhandled platform error: $error\n$stack');
    }
    return true;
  };

  await runZonedGuarded(() async {
    String? supabaseUrl;
    String? supabaseAnonKey;

    const defineUrl = String.fromEnvironment('SUPABASE_URL');
    const defineKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (defineUrl.isNotEmpty && defineKey.isNotEmpty) {
      supabaseUrl = defineUrl;
      supabaseAnonKey = defineKey;
    } else {
      try {
        await dotenv.load(fileName: '.env');
        supabaseUrl = dotenv.env['SUPABASE_URL'];
        supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Warning: Could not load .env file: $e');
        }
      }
    }

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

    if (kDebugMode) {
      debugPrint('SUPABASE_URL configured: ${supabaseUrl.isNotEmpty}');
      debugPrint('SUPABASE_ANON_KEY configured: ${supabaseAnonKey.isNotEmpty}');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    GoogleFonts.config.allowRuntimeFetching = true;

    runApp(
      const ProviderScope(
        child: RelsoftTeamFlowApp(),
      ),
    );
  }, (error, stack) {
    if (kDebugMode) {
      debugPrint('Unhandled zone error: $error\n$stack');
    }
  });
}
