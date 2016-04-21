#import "DNNotificationControllerExtended.h"
#import <objc/runtime.h>
#import "NSMutableDictionary+DNDictionary.h"
#import "NSDate+DNDateHelper.h"
#import "DNDonkyCore.h"
#import "DNNetworkController.h"
#import "DNConstants.h"

static NSString *const DNEventInteractivePushData = @"DonkyEventInteractivePushData";
static NSString *const DPPushNotificationID = @"notificationId";
static NSString *const DNInteractionResult = @"InteractionResult";

@implementation DNNotificationControllerExtended

+ (void)didReceiveNotification:(NSDictionary *)userInfo handleActionIdentifier:(NSString *)identifier completionHandler:(void (^)(NSString *))handler {
    
    BOOL background = [[UIApplication sharedApplication] applicationState] != UIApplicationStateActive;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (![[DNDonkyCore sharedInstance] serviceForType:DNEventInteractivePushData]) {
            [[DNDonkyCore sharedInstance] subscribeToLocalEvent:DNEventInteractivePushData handler:^(DNLocalEvent *event) {
                if ([event isKindOfClass:[DNLocalEvent class]]) {
                    if (handler) {
                        handler([event data]);
                    }
                }
            }];
            [[DNDonkyCore sharedInstance] registerService:DNEventInteractivePushData instance:self];
        }

        if (identifier) {
            NSString *url = [userInfo[@"lbl1"] isEqualToString:identifier] ? userInfo[@"link1"] : userInfo[@"link2"];
            if (handler) {
                handler(url);
            }
        }

        NSString *notificationID = userInfo[DPPushNotificationID];
        //Publish background notification event:

        if (background) {
            
            NSString * pushNotificationId = [NSString stringWithFormat:@"com.donky.push.%@", notificationID];
            [[NSUserDefaults standardUserDefaults] setObject:notificationID forKey:pushNotificationId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            DNLocalEvent *backgroundNotificationEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventBackgroundNotificationReceived
                                                                                      publisher:NSStringFromClass([self class])
                                                                                      timeStamp:[NSDate date]
                                                                                           data:@{@"NotificationID" : notificationID}];
            [[DNDonkyCore sharedInstance] publishEvent:backgroundNotificationEvent];
        }

        [[DNNetworkController sharedInstance] serverNotificationForId:notificationID success:^(NSURLSessionDataTask *task, id responseData) {
            if (identifier) {
                DNLocalEvent *interactionResult = [[DNLocalEvent alloc] initWithEventType:DNInteractionResult
                                                                                publisher:NSStringFromClass([self class])
                                                                                timeStamp:[NSDate date]
                                                                                     data:[DNNotificationControllerExtended reportButtonInteraction:identifier
                                                                                                                                   userInfo:responseData]];
                [[DNDonkyCore sharedInstance] publishEvent:interactionResult];
            }
            
            if (background) {
                [DNNotificationController loadNotificationMessage:responseData];
            }

            if (handler) {
                handler(nil);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (handler) {
                handler(nil);
            }
        }];
    });
}

+ (NSMutableDictionary *)reportButtonInteraction:(NSString *)identifier userInfo:(DNServerNotification *)notification {

    NSDate *interactionDate = [NSDate date];

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

    [params dnSetObject:@"iOS" forKey:@"operatingSystem"];
    [params dnSetObject:[interactionDate donkyDateForServer] forKey:@"interactionTimeStamp"];

    //First button set index:
    NSArray *buttonSetAction = [[notification data][@"buttonSets"] firstObject][@"buttonSetActions"];

    [params dnSetObject:[[buttonSetAction firstObject][@"label"] isEqualToString:identifier] ? @"Button1" : @"Button2" forKey:@"userAction"];

    [params dnSetObject:[[notification data][@"buttonSets"] firstObject][@"interactionType"] forKey:@"interactionType"];

    [params dnSetObject:[NSString stringWithFormat:@"%@|%@", [buttonSetAction firstObject][@"label"] ? : @"", [buttonSetAction lastObject][@"label"] ? : @""] forKey:@"buttonDescription"];

    //Set request ids:
    [params dnSetObject:[notification data][@"senderInternalUserId"] forKey:@"senderInternalUserId"];
    [params dnSetObject:[notification data][@"senderMessageId"] forKey:@"senderMessageId"];
    [params dnSetObject:[notification data][@"messageId"] forKey:@"messageId"];

    [params dnSetObject:[[notification createdOn] donkyDateForServer] forKey:@"messageSentTimeStamp"];
    
    double timeToInteract = [interactionDate timeIntervalSinceDate:[notification createdOn]];
    
    if (isnan(timeToInteract))
        timeToInteract = 0;
    
    [params dnSetObject:@(timeToInteract) forKey:@"timeToInteractionSeconds"];

    [params dnSetObject:[notification data][@"contextItems"] forKey:@"contextItems"];

    return params;
}

@end