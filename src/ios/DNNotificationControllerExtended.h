#import "DNNotificationController.h"
#import "DNServerNotification.h"

@interface DNNotificationControllerExtended : NSObject

+ (void)didReceiveNotification:(NSDictionary *)userInfo handleActionIdentifier:(NSString *)identifier completionHandler:(void (^)(NSString *))handler;

+ (NSMutableDictionary *)reportButtonInteraction:(NSString *)identifier userInfo:(DNServerNotification *)notification;

@end

@interface DNNotificationController (Extension)
+ (void)loadNotificationMessage:(DNServerNotification *)notification;
@end