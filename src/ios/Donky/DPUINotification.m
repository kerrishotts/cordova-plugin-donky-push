//
//  DPUINotification.m
//  Push UI Container
//
//  Created by Chris Wunsch on 15/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import "DPUINotification.h"
#import "DNServerNotification.h"
#import "NSDate+DNDateHelper.h"
#import "DCUILocalization+Localization.h"

@interface DPUINotification ()

@end

@implementation DPUINotification

- (instancetype)initWithNotification:(DNServerNotification *)notification {

    self = [super initWithNotification:notification];

    if (self) {


    }

    return self;
}

@end
