//
//  DPUINotificationController.m
//  Push UI Container
//
//  Created by Donky Networks on 15/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import "DPUINotificationController+Extended.h"
#import "DPUINotification.h"
#import "DNConstants.h"
#import "DNDonkyCore.h"
#import "NSDate+DNDateHelper.h"
#import "DPUIBannerView.h"
#import "DCMConstants.h"
#import "DNLoggingController.h"

@interface DPUINotificationControllerExtended ()
@property(nonatomic, strong) DPPushNotificationController *pushNotificationController;
@property(nonatomic, strong) DCUINotificationController *notificationController;
@property(nonatomic, strong ) DNLocalEventHandler pushReceivedHandler;
@property(nonatomic, strong) DNLocalEventHandler bannerTappedHandler;
@property(nonatomic, strong) DNServerNotification *previousNotification;
@end

@implementation DPUINotificationControllerExtended

#pragma mark -
#pragma mark - Setup Singleton

+(DPUINotificationControllerExtended *)sharedInstance
{
    static DPUINotificationControllerExtended *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DPUINotificationControllerExtended alloc] initPrivate];
    });
    return sharedInstance;
}

-(instancetype)init
{
    return [self initPrivate];
}

-(instancetype)initPrivate
{
    self  = [super init];
    if (self) {
        //Start Push Logic:
        [self setPushNotificationController:[[DPPushNotificationController alloc] init]];
        [[self pushNotificationController] start];
        
        [self setPlayAduio:YES];
    }
    
    return self;
}

- (void)start {
    
    __weak DPUINotificationControllerExtended *weakSelf = self;
    
    [self setPushReceivedHandler:^(DNLocalEvent *event) {
        if ([event isKindOfClass:[DNLocalEvent class]]) {
            [weakSelf pushNotificationReceived:[event data]];
        }
    }];
    
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyNotificationSimplePush handler:[self pushReceivedHandler]];
    
    [self setBannerTappedHandler:^(DNLocalEvent *event) {
        if ([[event data] isKindOfClass:[NSDictionary class]]) {
            DPUINotification *notification = [event data][@"Notification"];
            if ([[notification messageType] isEqualToString:@"SimplePush"]) {
                NSDictionary *userTapped = [event data][@"UserTapped"];
                DNDebugLog(@"User tapped: %@\nSubscribe to kDNDonkyNotificationSimplePush to receive this event too.", userTapped);
                [[weakSelf notificationController] bannerDismissTimerDidTick];
            }
        }
    }];
    
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyEventNotificationTapped handler:[self bannerTappedHandler]];
    
    DNModuleDefinition *simplePushUIController = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.1.3.0"];
    [[DNDonkyCore sharedInstance] registerModule:simplePushUIController];
    
}

- (void)stop {
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDNDonkyNotificationSimplePush handler:[self pushReceivedHandler]];
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDNDonkyNotificationSimplePush handler:[self bannerTappedHandler]];
    
    [self setBannerTappedHandler:nil];
    [self setPushNotificationController:nil];
}

#pragma mark -
#pragma mark - Core Logic

- (void)pushNotificationReceived:(NSDictionary *)notificationData {
    
    if (![self notificationController]) {
        [self setNotificationController:[[DCUINotificationController alloc] init]];
    }
    
    __block BOOL duplicate = NO;
    
    NSString *backgroundNotification = notificationData[@"PendingPushNotifications"];
    
    if ([backgroundNotification isEqualToString:[[self previousNotification] serverNotificationID]]) {
        duplicate = YES;
    }

    DNServerNotification *notification = notificationData[kDNDonkyNotificationSimplePush];
    
    // Keep a copy of the current notification for the duplicate check
    [self setPreviousNotification:notificationData[kDNDonkyNotificationSimplePush]];
 
    NSDate *expired = [NSDate donkyDateFromServer:[notification data][@"expiryTimeStamp"]];
    
    BOOL messageExpired = NO;
    if (expired) {
        messageExpired = [expired donkyHasDateExpired];
    }
    
    if (!duplicate && !messageExpired) {
        
        DPUINotification *donkyNotification = [[DPUINotification alloc] initWithNotification:notification];
        DPUIBannerView *bannerView = [[DPUIBannerView alloc] initWithNotification:donkyNotification];
        [[self notificationController] presentNotification:bannerView];
        
        if ([self shouldPlayAudio]) {
            DNLocalEvent *event = [[DNLocalEvent alloc] initWithEventType:@"DAudioPlayAudioFile" publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:@(0)];
            [[DNDonkyCore sharedInstance] publishEvent:event];
        }
        
        //If we are on simple push, we add the other gestures:
        if (![bannerView buttonView]) {
            [[[self notificationController] notificationBannerView] configureGestures];
        }
    }
    else {
        [self reduceAppBadge:1];
    }
}

- (void)reduceAppBadge:(NSInteger)count {
    
    NSInteger currentCount = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    currentCount -= count;
    
    DNLocalEvent *changeBadgeEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkySetBadgeCount
                                                                   publisher:NSStringFromClass([self class])
                                                                   timeStamp:[NSDate date]
                                                                        data:@(currentCount)];
    [[DNDonkyCore sharedInstance] publishEvent:changeBadgeEvent];
}

@end