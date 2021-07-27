#import "FlutterUpdaterPlugin.h"
#if __has_include(<flutter_updater/flutter_updater-Swift.h>)
#import <flutter_updater/flutter_updater-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_updater-Swift.h"
#endif

@implementation FlutterUpdaterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterUpdaterPlugin registerWithRegistrar:registrar];
}
@end
