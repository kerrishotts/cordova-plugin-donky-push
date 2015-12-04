
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
    [DNNotificationController didReceiveNotification:userInfo handleActionIdentifier:nil completionHandler:^(NSString *string) {
        completionHandler(UIBackgroundFetchResultNewData);
        [[DNNetworkController sharedInstance] synchronise];
        
    }];
}


//For interactive notification only
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    NSLog(@"handleActionWithIdentifier with userInfo: %@", userInfo);
    [DNNotificationController didReceiveNotification:userInfo handleActionIdentifier:identifier completionHandler:^(NSString *string) {
        completionHandler();
    }];
}

@end
