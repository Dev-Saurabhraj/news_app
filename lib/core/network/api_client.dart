import 'dart:async';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../errors/api_exception.dart';
import '../errors/failures.dart';

class ApiClient {
  ApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 12),
          sendTimeout: const Duration(seconds: 8),
          responseType: ResponseType.json,
          validateStatus: (status) => status == null || status < 500,
        ),
      ) {
    _dio.interceptors.add(_RetryInterceptor(_dio));
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        requestHeader: false,
        responseHeader: false,
      ),
    );
  }

  final Dio _dio;

  Future<T> get<T>(String path) async {
    if (path.isEmpty) {
      throw const ApiException('Invalid request path: path cannot be empty.');
    }
    try {
      final response = await _dio.get<T>(path);
      final data = response.data;
      if (data == null) {
        throw const ApiException(
          'Hacker News returned an empty response.',
          type: FailureType.empty,
        );
      }
      return data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } catch (error) {
      throw ApiException(
        'Unexpected error during API request: $error',
        type: FailureType.unknown,
      );
    }
  }
}

class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;
  static const maxRetries = 3;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryCount = (err.requestOptions.extra['retryCount'] as int?) ?? 0;
    final isTransientError = {
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.connectionError,
    }.contains(err.type);

    // Treat 503 (service unavailable) and 429 (too many requests) as transient
    final statusCode = err.response?.statusCode;
    final isTransientStatus = statusCode == 503 || statusCode == 429;
    final canRetry =
        retryCount < maxRetries && (isTransientError || isTransientStatus);

    if (!canRetry) {
      handler.next(err);
      return;
    }

    final delayMs = 350 * (retryCount + 1) + (retryCount * 100);
    await Future<void>.delayed(Duration(milliseconds: delayMs));

    try {
      final response = await _dio.fetch<dynamic>(
        err.requestOptions..extra['retryCount'] = retryCount + 1,
      );
      handler.resolve(response);
    } on DioException catch (error) {
      handler.next(error);
    }
  }
}
