import 'package:erp_app/src/app.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Reemplaza estos valores con tus credenciales de Supabase
/// o pásalos como defines en tiempo de compilación.
const String _defaultSupabaseUrl = 'https://hgsxkwgmxjwkbcxyabgj.supabase.co';
const String _defaultSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhnc3hrd2dteGp3a2JjeHlhYmdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc0Nzc0NDAsImV4cCI6MjA4MzA1MzQ0MH0.CW0xlbDygxCEz7yOr0-JF2h7e6n8G9rlCQdu5zmw4sA';

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
