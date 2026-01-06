import 'package:erp_app/src/app.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Reemplaza estos valores con tus credenciales de Supabase
/// o pásalos como defines en tiempo de compilación.
const String _defaultSupabaseUrl = 'https://tprfoynewsbnwycqdznt.supabase.co';
const String _defaultSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRwcmZveW5ld3Nibnd5Y3Fkem50Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2NDYzMjgsImV4cCI6MjA4MzIyMjMyOH0.FDAWCcR0C2EA7CN9wiVOG-uMVxMeWGBPqAaIUWeFZUU';

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
