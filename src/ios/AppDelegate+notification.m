
#import "AppDelegate+notification.h"
#import "DNNotificationController.h"
#import "DNNetworkController.h"
#import <objc/runtime.h>


@implementation AppDelegate (notification)


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog([NSString stringWithFormat:@"Device Token=%@",deviceToken]);
    [DNNotificationController registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSString *str = [NSString stringWithFormat: @"Error: %@", error];
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError - %@",str);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    NSLog(@"didReceiveRemoteNotification with userInfo: %@", userInfo);
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    BOOL wasLaunchedFromNotification = (state == UIApplicationStateInactive);
    
    NSString *identifier = [userInfo[@"inttype"] isEqualToString:@"OneButton"] ? userInfo[@"lbl1"] : nil;
    [DNNotificationController didReceiveNotification:userInfo handleActionIdentifier:identifier completionHandler:^(NSString *linkToOpen) {
        if(wasLaunchedFromNotification)
        {
            [self handleDeepLink:linkToOpen];
        }
        completionHandler(UIBackgroundFetchResultNewData);
        [[DNNetworkController sharedInstance] synchronise];
    }];
}


//For interactive notification only
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    NSLog(@"handleActionWithIdentifier with userInfo: %@", userInfo);
    [DNNotificationController didReceiveNotification:userInfo handleActionIdentifier:identifier completionHandler:^(NSString *linkToOpen) {
        [self handleDeepLink:linkToOpen];
        completionHandler(UIBackgroundFetchResultNewData);
    }];
}

@end
