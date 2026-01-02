import 'package:erp_app/src/auth/auth_page.dart';
import 'package:erp_app/src/shell/shell_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<AuthState> _authStateStream =
      Supabase.instance.client.auth.onAuthStateChange;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authStateStream,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ??
            Supabase.instance.client.auth.currentSession;

        if (session == null) {
          return const AuthPage();
        }

        return const ShellPage();
      },
    );
  }
}
