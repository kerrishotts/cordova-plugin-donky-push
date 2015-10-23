#import "DonkyPushPlugin.h"

#define DLog(fmt, ...) { \
NSLog((@"DonkyPushPlugin: " fmt), ##__VA_ARGS__); \
}

@implementation DonkyPushPlugin

@synthesize cordova_command;
@synthesize pushNotificationController;
@synthesize pushUINotificationController;

/*
 * API
 */
- (void) init:(CDVInvokedUrlCommand*)command;
{
    self.cordova_command = command;
    
    @try {
        BOOL usePushUI = [[command argumentAtIndex:0] boolValue];
        
        if(usePushUI){
            DLog(@"Init Donky Push UI/Logic");
            self.pushUINotificationController = [[DPUINotificationController alloc] init];
            [self.pushUINotificationController start];
        }else{
            DLog(@"Init Donky Push Logic");
            self.pushNotificationController = [[DPPushNotificationController alloc] init];
            [self.pushNotificationController start];
        }
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]];
    }
    @catch (NSException *exception) {
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason]];
    }
}

/*
 * Internals
 */
- (void) sendPluginResult:(CDVPluginResult*)pluginResult;
{
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.cordova_command.callbackId];
}

@end
