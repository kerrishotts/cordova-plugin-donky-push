#ifdef CORDOVA_FRAMEWORK
#import <CORDOVA/CDVPlugin.h>
#else
#import "CORDOVA/CDVPlugin.h"
#endif

#import "DNDonkyCore.h"
#import "DNModuleDefinition.h"

@interface DonkyPlugin :CDVPlugin {
    CDVInvokedUrlCommand* cordova_command;
    DNModuleDefinition* moduleDefinition;
}
@property (nonatomic,retain) CDVInvokedUrlCommand* cordova_command;
@property (nonatomic,retain) DNModuleDefinition* moduleDefinition;

+ (UIWebView*) webView;
+ (bool) sdkInitialised;
+ (bool) cordovaInitialised;

+ (void) sdkIsReady;
- (CDVPlugin*)xxx_initWithWebView:(UIWebView*)theWebView;

- (void) updateUserDetails:(CDVInvokedUrlCommand*)command;
- (void) updateDeviceDetails:(CDVInvokedUrlCommand*)command;
- (void) updateRegistrationDetails:(CDVInvokedUrlCommand*)command;
- (void) replaceRegistrationDetails:(CDVInvokedUrlCommand*)command;
- (void) sendContentNotificationToUser:(CDVInvokedUrlCommand*)command;
- (void) sendContentNotificationToUsers:(CDVInvokedUrlCommand*)command;
- (void) synchronise:(CDVInvokedUrlCommand*)command;
- (void) subscribeToContentNotifications:(CDVInvokedUrlCommand*)command;
@end