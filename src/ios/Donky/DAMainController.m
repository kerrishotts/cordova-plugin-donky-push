//
//  DAMainController.m
//  DonkyCommonAudio
//
//  Created by Chris Wunsch on 31/07/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "DAMainController.h"
#import "DNConstants.h"
#import "DNLoggingController.h"
#import "DNDonkyCore.h"

static NSString *const DAMiscellaneous = @"DAMisc";
static NSString *const DAPlayFile = @"DAudioPlayAudioFile";

@interface DAMainController ()
@property (nonatomic, strong) DNLocalEventHandler audioFileHandler;
@property (nonatomic, strong) NSMutableDictionary *audioFiles;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@end

@implementation DAMainController

+(DAMainController *)sharedInstance
{
    static dispatch_once_t pred;
    static DAMainController *sharedInstance = nil;

    dispatch_once(&pred, ^{
        sharedInstance = [[DAMainController alloc] initPrivate];
    });

    return sharedInstance;
}

-(instancetype)init {
    return [self initPrivate];
}

-(instancetype)initPrivate
{
    self  = [super init];

    if (self) {

        [self setAudioFiles:[[NSMutableDictionary alloc] init]];
        [self setVibrate:YES];

    }

    return self;
}

- (void)start {
    
    __typeof__(self) __weak weakSelf = self;
    [self setAudioFileHandler:^(DNLocalEvent *event) {
        [weakSelf playAudioFileForMessage:[[event data] integerValue]];
    }];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:DAPlayFile handler:[self audioFileHandler]];

    DNModuleDefinition *moduleDefinition = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.0.0.0"];
    [[DNDonkyCore sharedInstance] registerModule:moduleDefinition];
    
    [[DNDonkyCore sharedInstance] registerService:NSStringFromClass([self class]) instance:self];
    
}

- (void)stop {
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:DAPlayFile handler:[self audioFileHandler]];
}

- (void)playAudioFileForMessage:(NSInteger)messageType {
    NSURL *audioFile = nil;

    switch (messageType) {
        case 0:
            audioFile = [self audioFiles][kDNDonkyNotificationSimplePush];
            break;
        case 1:
            audioFile = [self audioFiles][kDNDonkyNotificationRichMessage];
            break;
        case 2:
            audioFile = [self audioFiles][kDNDonkyNotificationCustomDataKey];
            break;
        case 3:
            audioFile = [self audioFiles][kDNDonkyNotificationChatMessage];
            break;
        case 4:
            audioFile = [self audioFiles][DAMiscellaneous];
            break;
    default:break;
    }

    if ([self shouldVibrate]) {
        if (messageType & DAMisc) {
            DNInfoLog(@"donky does not vibrate with misc message type");
        }
        else {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }
    }

    //Play audio file:
    if (!audioFile) {
        DNErrorLog(@"cannot play audio for message type: %lu, have you saved the audio file name?", (unsigned long)messageType);
        return;
    }

#if TARGET_IPHONE_SIMULATOR
    DNErrorLog(@"Sometimes playing audio on simulator can cause an exception...");
    return;
#else

    NSError *error;
    [self setAudioPlayer:[[AVAudioPlayer alloc] initWithContentsOfURL:audioFile error:&error]];
    [[self audioPlayer] play];

    if (error) {
        DNErrorLog(@"couldn't play audio file: %@", [error localizedDescription]);
    }
#endif
}

+ (void)playAuioFileForMessage:(NSInteger)messageType {
    [[DAMainController sharedInstance] playAudioFileForMessage:messageType];
}

- (void)setAudioFile:(NSURL *)audioFile forMessageType:(DonkyAudioMessageTypes)messageType {
    if (messageType & DASimplePushMessage) {
        [self audioFiles][kDNDonkyNotificationSimplePush] = audioFile;
    }
    if (messageType & DARichMessage) {
        [self audioFiles][kDNDonkyNotificationRichMessage] = audioFile;
    }
    if (messageType & DACustomContent) {
        [self audioFiles][kDNDonkyNotificationCustomDataKey] = audioFile;
    }
    if (messageType & DAChatMessage) {
        [self audioFiles][kDNDonkyNotificationChatMessage] = audioFile;
    }
    if (messageType & DAMisc) {
        [self audioFiles][DAMiscellaneous] = audioFile;
    }
}

+ (void)setAudioFile:(NSURL *)audioFile forMessageType:(DonkyAudioMessageTypes)messageType {
    [[DAMainController sharedInstance] setAudioFile:audioFile forMessageType:messageType];
}

@end