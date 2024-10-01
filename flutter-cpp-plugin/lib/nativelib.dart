import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pool/pool.dart';

class Nativelib {
  static const MethodChannel _channel = MethodChannel('nativelib');

  /// [Pool] for running operations that require mutually exclusive access to Nativelib.
  ///
  /// The intended usage is to call [Pool].withResource to wrap such operations.
  /// This is needed since it is not generally safe for non-atomic Nativelib operations to run concurrently.
  ///
  /// The pool has a timeout of 3 seconds, to avoid deadlocks, by canceling the operation.
  static final mutexPool = Pool(1, timeout: const Duration(seconds: 3));

  static Future<dynamic> call(String method, [dynamic arguments]) async {
    /// Calls a native method with the given arguments.
    /// [method] is the name of the method to call.
    /// [arguments] are the arguments to pass to the method.
    ///
    /// throws ArgumentError if [method] is empty.
    /// throws PlatformException if the native method fails.

    if (method.isEmpty) {
      throw ArgumentError.notNull("method");
    }

    try {
      return await _channel.invokeMethod(method, arguments);
    } on PlatformException {
      rethrow;
    }
  }
}
