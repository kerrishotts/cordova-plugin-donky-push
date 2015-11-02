//
//  DCUIAvatarImageView.h
//  RichInbox
//
//  Created by Chris Wunsch on 05/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCUIAvatarImageView : UIImageView

/*!
 Initialiser to create a new UIImageView for the SDKs avatars.
 
 @param borderColour the colour of the avatars border.
 
 @return a new DCUIAvatarImageView
 
 @since 2.2.2.7
 */
- (instancetype)initWithBorderColour:(UIColor *)borderColour;

- (void)setBorderColour:(UIColor *)color;

@end
