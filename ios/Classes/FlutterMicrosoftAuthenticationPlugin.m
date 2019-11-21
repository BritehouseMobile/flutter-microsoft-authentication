#import "FlutterMicrosoftAuthenticationPlugin.h"
#import <flutter_microsoft_authentication/flutter_microsoft_authentication-Swift.h>

@implementation FlutterMicrosoftAuthenticationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterMicrosoftAuthenticationPlugin registerWithRegistrar:registrar];
}
@end
