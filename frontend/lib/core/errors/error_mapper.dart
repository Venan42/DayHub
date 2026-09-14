import 'dart:convert';
import 'package:dio/dio.dart';
import 'failure.dart';

class ErrorMapper {
  static Failure fromDioException(DioException e) {
    try {
      return _map(e);
    } catch (_) {
      return const UnknownFailure('Ocorreu um erro inesperado. Tente novamente.');
    }
  }

  static Failure _map(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure('Não foi possível conectar ao servidor.');
    }

    final response = e.response;
    if (response == null) {
      return const UnknownFailure('Erro inesperado. Tente novamente.');
    }

    final data = _normalize(response.data);
    final status = response.statusCode ?? 0;

    final genericMessage = (data is Map && data['detail'] is String)
        ? data['detail'] as String
        : 'Ocorreu um erro. Tente novamente.';

    switch (status) {
      case 400:
        return ValidationFailure(genericMessage, _extractFieldErrors(data));
      case 401:
        return const UnauthorizedFailure('Credenciais inválidas.');
      case 409:
        return ConflictFailure(genericMessage);
      default:
        if (status >= 500) {
          return const ServerFailure('Erro no servidor. Tente novamente mais tarde.');
        }
        return UnknownFailure(genericMessage);
    }
  }

  static dynamic _normalize(dynamic rawData) {
    if (rawData is Map || rawData is List) return rawData;
    if (rawData is String && rawData.trim().isNotEmpty) {
      try {
        return jsonDecode(rawData);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Map<String, String> _extractFieldErrors(dynamic data) {
    final result = <String, String>{};
    if (data is! Map) return result;

    final extra = data['extra'];
    if (extra is! List) return result;

    for (final item in extra) {
      if (item is! Map) continue;

      final rawKey = item['key'] ?? item['loc'];
      String? key;
      if (rawKey is String) {
        key = rawKey;
      } else if (rawKey is List && rawKey.isNotEmpty) {
        key = rawKey.last.toString(); 
      }

      final message = item['message'] ?? item['msg'];
      if (key != null && key.isNotEmpty && message != null) {
        result[key] = message.toString();
      }
    }

    return result;
  }
}