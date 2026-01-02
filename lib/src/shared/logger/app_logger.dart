import 'dart:convert';
import 'dart:developer' as developer;

/// Logger centralizado para eventos de navegación y acciones.
///
/// Por ahora emite registros a `dart:developer.log` en formato JSON para que
/// podamos depurar fácilmente qué sección/acción se ejecutó. Si más adelante
/// necesitamos enviar esta información a un servicio externo sólo hay que
/// actualizar esta clase.
class AppLogger {
  const AppLogger._();

  static void event(String name, {Map<String, dynamic>? payload}) {
    final entry = <String, dynamic>{
      'event': name,
      'timestamp': DateTime.now().toIso8601String(),
      if (payload != null) ...payload,
    };
    developer.log(
      jsonEncode(entry),
      name: 'app_event',
    );
  }

  static void error(
    String name,
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? payload,
  }) {
    final entry = <String, dynamic>{
      'event': name,
      'timestamp': DateTime.now().toIso8601String(),
      'error': error.toString(),
      if (payload != null) ...payload,
    };
    developer.log(
      jsonEncode(entry),
      name: 'app_error',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
