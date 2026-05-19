import 'package:dio/dio.dart';

import 'failures.dart';

class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.type = FailureType.unknown,
  });

  final String message;
  final int? statusCode;
  final FailureType type;

  Failure toFailure() =>
      Failure(message: message, statusCode: statusCode, type: type);

  static ApiException fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          'The request timed out. Pull to try again.',
          type: FailureType.timeout,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'No internet connection. Check your network and retry.',
          type: FailureType.network,
        );
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        if (status == 401) {
          return const ApiException(
            'Unauthorized access to Hacker News.',
            statusCode: 401,
            type: FailureType.unauthorized,
          );
        } else if (status == 404) {
          return const ApiException(
            'This Hacker News item could not be found.',
            statusCode: 404,
            type: FailureType.notFound,
          );
        } else if (status == 429) {
          return const ApiException(
            'Too many requests. Please wait and try again.',
            statusCode: 429,
            type: FailureType.server,
          );
        } else if (status == 503) {
          return const ApiException(
            'Hacker News service is temporarily unavailable. Retrying...',
            statusCode: 503,
            type: FailureType.server,
          );
        }
        return ApiException(
          'Hacker News is not responding cleanly right now.',
          statusCode: status,
          type: FailureType.server,
        );
      case DioExceptionType.cancel:
        return const ApiException('The request was cancelled.');
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const ApiException(
          'Something unexpected happened while loading data.',
        );
    }
  }
}
