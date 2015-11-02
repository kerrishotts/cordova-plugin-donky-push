//
//  DRIViewHelper.h
//  RichInbox
//
//  Created by Chris Wunsch on 07/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DNRichMessage.h"
#import "DRITableViewController.h"

@interface DRIViewHelper : NSObject

+ (void)presentCellActionSheet:(DRITableViewController *)viewController withMessage:(DNRichMessage *)richMessage atIndexPath:(NSIndexPath *)indexPath senderFrame:(CGRect)senderFrame;

+ (DRIOptionsView *)optionsViewForView:(DRITableViewController *)viewController;

+ (void)showDeleteAlert:(DRITableViewController *)viewController richMessage:(DNRichMessage *)richMessage selectedIndex:(NSInteger)index;

@end
