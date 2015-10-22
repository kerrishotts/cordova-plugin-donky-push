#ifdef CORDOVA_FRAMEWORK
#import <CORDOVA/CDVPlugin.h>
#else
#import "CORDOVA/CDVPlugin.h"
#endif


@interface DonkyPushPlugin :CDVPlugin {
    CDVInvokedUrlCommand* cordova_command;
}
@property (nonatomic,retain) CDVInvokedUrlCommand* cordova_command;

@end