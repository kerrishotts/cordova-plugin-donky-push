//
//  DRITableViewCellExpirationHelper.h
//  RichInbox
//
//  Created by Chris Wunsch on 27/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNRichMessage.h"
#import "DRITableViewCell.h"

@interface DRITableViewCellExpirationHelper : NSObject

+ (NSTimer *)expiryTimerForMessage:(DNRichMessage *)richMessage target:(DRITableViewCell *)target;

@end
