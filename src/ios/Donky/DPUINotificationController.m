//
//  DPUINotificationController.m
//  Push UI Container
//
//  Created by Chris Wunsch on 15/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import "DPUINotificationController.h"
#import "DPUINotification.h"
#import "DNConstants.h"
#import "DNDonkyCore.h"
#import "NSDate+DNDateHelper.h"
#import "DPUIBannerView.h"
#import "DCMConstants.h"

@interface DPUINotificationController ()
@property(nonatomic, strong) DPPushNotificationController *pushNotificationController;
@property(nonatomic, strong) DCUINotificationController *notificationController;
@property(nonatomic, strong ) DNLocalEventHandler pushReceivedHandler;
@property(nonatomic, strong) DNLocalEventHandler bannerTappedHandler;
@property(nonatomic, strong) DNServerNotification *notification;
@end

@implementation DPUINotificationController

#pragma mark -
#pragma mark - Setup Singleton

+(DPUINotificationController *)sharedInstance
{
    static DPUINotificationController *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[DPUINotificationController alloc] initPrivate];
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

    __weak DPUINotificationController *weakSelf = self;

    [self setPushReceivedHandler:^(DNLocalEvent *event) {
        if ([event isKindOfClass:[DNLocalEvent class]]) {
            [weakSelf pushNotificationReceived:[event data]];
        }
    }];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyNotificationSimplePush handler:[self pushReceivedHandler]];
    
    [self setBannerTappedHandler:^(DNLocalEvent *event) {
        if ([[event data][@"type"] isEqualToString:kDNDonkyNotificationSimplePush]) {
            [[weakSelf notificationController] bannerDismissTimerDidTick];
        }
    }];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyEventNotificationTapped handler:[self bannerTappedHandler]];
    
    DNModuleDefinition *simplePushUIController = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.1.1.1"];
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

    if ([backgroundNotification isEqualToString:[[self notification] serverNotificationID]]) {
        duplicate = YES;
    }
    
    NSDate *expired = [NSDate donkyDateFromServer:[[self notification] data][@"expiryTimeStamp"]];

    BOOL messageExpired = NO;
    if (expired) {
        messageExpired = [expired donkyHasDateExpired];
    }
    
    if (!duplicate && !messageExpired) {
        [self setNotification:notificationData[kDNDonkyNotificationSimplePush]];
        
        DPUINotification *donkyNotification = [[DPUINotification alloc] initWithNotification:[self notification]];
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
