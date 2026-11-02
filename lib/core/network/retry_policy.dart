import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

typedef Delay = Future<void> Function(Duration duration);
typedef UtcNow = DateTime Function();
typedef RetryJitter = Duration Function(int retryIndex);

final class RetryPolicy {
  const RetryPolicy({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.delay = _defaultDelay,
    this.now = _defaultNow,
    this.jitter = _defaultJitter,
  }) : assert(maxAttempts > 0);

  final int maxAttempts;
  final Duration baseDelay;
  final Delay delay;
  final UtcNow now;
  final RetryJitter jitter;

  Future<Response<T>> get<T>(
    Dio dio,
    String path, {
    CancelToken? cancelToken,
  }) async {
    for (var attempt = 1; ; attempt++) {
      try {
        return await dio.get<T>(path, cancelToken: cancelToken);
      } on DioException catch (error) {
        if (attempt >= maxAttempts || !_isRetryable(error)) {
          rethrow;
        }
        final retryDelay =
            _retryAfter(error) ??
            (baseDelay * (1 << (attempt - 1))) + jitter(attempt);
        await _wait(retryDelay, cancelToken);
      }
    }
  }

  bool _isRetryable(DioException error) {
    if (CancelToken.isCancel(error)) {
      return false;
    }
    final statusCode = error.response?.statusCode;
    if (statusCode == 429 || (statusCode != null && statusCode >= 500)) {
      return true;
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      _ => false,
    };
  }

  Duration? _retryAfter(DioException error) {
    if (error.response?.statusCode != 429) {
      return null;
    }
    final value = error.response?.headers.value('retry-after')?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    final seconds = int.tryParse(value);
    if (seconds != null && seconds >= 0) {
      return Duration(seconds: seconds);
    }
    try {
      final instant = HttpDate.parse(value).toUtc();
      final difference = instant.difference(now());
      return difference.isNegative ? Duration.zero : difference;
    } on FormatException {
      return null;
    }
  }

  Future<void> _wait(Duration duration, CancelToken? cancelToken) async {
    if (cancelToken == null) {
      await delay(duration);
      return;
    }
    if (cancelToken.isCancelled) {
      throw cancelToken.cancelError!;
    }
    await Future.any<void>([
      delay(duration),
      cancelToken.whenCancel.then<void>((error) => throw error),
    ]);
  }

  static Future<void> _defaultDelay(Duration duration) =>
      Future.delayed(duration);
  static DateTime _defaultNow() => DateTime.now().toUtc();
  static Duration _defaultJitter(int retryIndex) =>
      Duration(milliseconds: (retryIndex * 83) % 251);
}
