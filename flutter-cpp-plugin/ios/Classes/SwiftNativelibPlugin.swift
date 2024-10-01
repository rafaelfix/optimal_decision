import Flutter
import UIKit

public class SwiftNativelibPlugin: NSObject, FlutterPlugin {

  var nlib = nativelib()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "nativelib", binaryMessenger: registrar.messenger())
    let instance = SwiftNativelibPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      var args = [Any]()
      if (call.arguments != nil) {
          args = (call.arguments as! [Any])
      }
      
    result(nlib.runFunction(call.method, args: args))
  }
}
