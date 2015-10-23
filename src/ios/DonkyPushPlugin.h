#ifdef CORDOVA_FRAMEWORK
#import <CORDOVA/CDVPlugin.h>
#else
#import "CORDOVA/CDVPlugin.h"
#endif

#import "DPPushNotificationController.h"
#import "DPUINotificationController.h"

@interface DonkyPushPlugin :CDVPlugin {
    CDVInvokedUrlCommand* cordova_command;
    DPPushNotificationController* pushNotificationController;
    DPUINotificationController* pushUINotificationController;
}
@property (nonatomic,retain) CDVInvokedUrlCommand* cordova_command;
@property (nonatomic, strong) DPPushNotificationController* pushNotificationController;
@property (nonatomic, strong) DPUINotificationController* pushUINotificationController;

- (void) init:(CDVInvokedUrlCommand*)command;

@end