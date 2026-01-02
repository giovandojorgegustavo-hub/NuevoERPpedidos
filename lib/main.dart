import 'package:erp_app/src/app.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Reemplaza estos valores con tus credenciales de Supabase
/// o pásalos como defines en tiempo de compilación.
const String _defaultSupabaseUrl = 'https://pxxiqaasskbkyuixswlo.supabase.co';
const String _defaultSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4eGlxYWFzc2tia3l1aXhzd2xvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY4NTc5NzMsImV4cCI6MjA4MjQzMzk3M30.eWPat2tjePGs0txef0L4WvCoryTG2wtBEDCymUga9HY';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeSupabase();
  runApp(const ErpApp());
}

Future<void> _initializeSupabase() async {
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: _defaultSupabaseUrl,
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: _defaultSupabaseAnonKey,
  );

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'Configura SUPABASE_URL y SUPABASE_ANON_KEY antes de iniciar la app.',
    );
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
}
