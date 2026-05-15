import 'dart:async';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../errors/api_exception.dart';

class ApiClient {
  ApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 12),
          sendTimeout: const Duration(seconds: 8),
          responseType: ResponseType.json,
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
    try {
      final response = await _dio.get<T>(path);
      final data = response.data;
      if (data == null) {
        throw const ApiException('Hacker News returned an empty response.');
      }
      return data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryCount = (err.requestOptions.extra['retryCount'] as int?) ?? 0;
    final canRetry =
        retryCount < 2 &&
        {
          DioExceptionType.connectionTimeout,
          DioExceptionType.receiveTimeout,
          DioExceptionType.connectionError,
        }.contains(err.type);

    if (!canRetry) {
      handler.next(err);
      return;
    }

    await Future<void>.delayed(Duration(milliseconds: 350 * (retryCount + 1)));
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
