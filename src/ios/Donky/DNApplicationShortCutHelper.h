//
//  DNApplicationShortCutHelper.h
//  ChatUI
//
//  Created by Chris Wunsch on 03/10/2015.
//  Copyright © 2015 Chris Wunsch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>

@interface DNApplicationShortCutHelper : NSObject

+ (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler;

@end
