//
//  DNOutboundModules.m
//  Core Container
//
//  Created by Chris Wunsch on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNLoggingController.h"
#import "DNOutboundModules.h"
#import "DNModuleDefinition.h"
#import "DNSubscription.h"
#import "DNModuleHelper.h"

@interface DNOutboundModules ()
@property(nonatomic, strong) NSMutableDictionary *outboundModules;
@end

@implementation DNOutboundModules

- (instancetype) init {
    
    self = [super init];
    
    if (self) {
        [self setOutboundModules:[[NSMutableDictionary alloc] init]];
    }

    return self;
}

- (void)subscribeToOutboundNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions {
    [subscriptions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNSubscription class]]) {
            DNErrorLog(@"Something has gone wrong with. Expected DNSubscription (or subclass thereof) got: %@... Bailing out", NSStringFromClass([obj class]));
        }
        else {
            DNSubscription *subscription = obj;
            [DNModuleHelper addModule:moduleDefinition toModuleList:[self outboundModules] subscription:subscription];
        }
    }];
}

- (void)unSubscribeToOutboundNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions {
    [subscriptions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNSubscription class]]) {
            DNErrorLog(@"Something has gone wrong with. Expected DNSubscription (or subclass thereof) got: %@... Bailing out", NSStringFromClass([obj class]));
        }
        else {
            DNSubscription *subscription = obj;
            [DNModuleHelper removeModule:moduleDefinition toModuleList:[self outboundModules] subscription:subscription];
        }
    }];
}

- (void)publishOutboundNotification:(NSString *)type data:(id)data {
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSArray *outboundSubscribers = [[self outboundModules][type] allObjects];
            [outboundSubscribers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (![obj isKindOfClass:[DNSubscription class]]) {
                    DNErrorLog(@"Something has gone wrong with. Expected DNSubscription (or subclass thereof) got: %@... Bailing out", NSStringFromClass([obj class]));
                }
                else {
                    DNSubscription *subscription = obj;
                    if ([subscription handler]) {
                        [subscription handler](data);
                    }
                }
            }];
        });
    }
    else {
        DNInfoLog(@"Application is not active, cannot publish notifications. If this was a background notification and you want to receive it, then you need to subscribe to the following local notifications: kDNDonkyEventBackgroundNotificationReceived (alerts about a simple received, passing in the notification ID || kDNDonkyEventNotificationLoaded (alerts when received in backround too but passes a DNServerNotification object.");
    }
}


@end
