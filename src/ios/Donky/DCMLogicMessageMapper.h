//
//  DCMLogicMessageMapper.h
//  RichLogic
//
//  Created by Chris Wunsch on 08/08/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNServerNotification.h"
#import "DNMessage.h"

@interface DCMLogicMessageMapper : NSObject

+ (void)upsertServerNotification:(DNServerNotification *)serverNotification toMessage:(DNMessage *)message;

@end
