package com.example.nativelib

import androidx.annotation.NonNull
import android.util.Log 

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** NativelibPlugin */
class NativelibPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "nativelib")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    val native = NLib()
    
    var args: ArrayList<Any> = arrayListOf()

    // TODO:  Fråga folk om vad de tycker om det här. Imo känns "hackingt" kanske men vi vill ju
    //        att den ska krasha om den inte får en lista...
    if (call.arguments != null) {
      args = call.arguments as ArrayList<Any>
    }

    try {
      var res = native.runFunction(call.method, *args.toArray())
      // Log.d("NativelibPlugin", "Result: " + res)

      if (res == Unit) { // Unit is the default return value for void functions
        result.success(null)
      } else {
        result.success(res)
      }
    } catch (e: Exception) {
      result.error("nativelib", e.message, null) // PlatformException in dart
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
