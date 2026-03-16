import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({String? baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout:
          Duration(seconds: AppConstants.apiTimeoutSeconds),
      receiveTimeout:
          Duration(seconds: AppConstants.apiTimeoutSeconds),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-User-Email': dotenv.env['KELSA_USER_EMAIL'] ?? '',
        'X-User-Token': dotenv.env['KELSA_USER_TOKEN'] ?? '',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint('[API] $obj'),
    ));
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.post<T>(path, data: data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.put<T>(path, data: data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  AppException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        String message = 'Server error';
        if (data is Map && data.containsKey('error')) {
          message = data['error'].toString();
        } else if (data is Map && data.containsKey('message')) {
          message = data['message'].toString();
        }
        return NetworkException(
          message,
          statusCode: statusCode,
          originalError: e,
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          'No internet connection. Please check your network.',
          code: 'NO_CONNECTION',
        );
      default:
        return AppException(
          e.message ?? 'An unexpected error occurred',
          originalError: e,
        );
    }
  }
}
