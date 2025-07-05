
// lib/utils/js_stub.dart

// Stub for the 'dart:js' library.
// This is used when the app is not running on the web.

class JsContext {
  void callMethod(String method, [List? args]) {
    // This is a stub, so it does nothing.
    // It's here to prevent compile-time errors on non-web platforms.
    throw UnimplementedError('dart:js is not available on this platform.');
  }
}

final JsContext context = JsContext();
