#import "NativelibPlugin.h"
#if __has_include(<nativelib/nativelib-Swift.h>)
#import <nativelib/nativelib-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "nativelib-Swift.h"
#endif

@implementation NativelibPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNativelibPlugin registerWithRegistrar:registrar];
}
@end
