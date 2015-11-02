//
//  DCUIAvatarImageView.m
//  RichInbox
//
//  Created by Chris Wunsch on 05/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "DCUIAvatarImageView.h"
#import "DCUIConstants.h"

@implementation DCUIAvatarImageView

- (instancetype)initWithBorderColour:(UIColor *)borderColour {

    self = [super init];

    if (self) {

        [[self layer] setCornerRadius:kDCUIAvatarHeight / 2.0f];
        [[self layer] setMasksToBounds:YES];
        [[self layer] setBorderWidth:0.50];

        [[self layer] setBorderColor:borderColour.CGColor];

    }

    return self;
}

- (void)setBorderColour:(UIColor *)color {
    [[self layer] setBorderColor:[color CGColor]];
}

@end
