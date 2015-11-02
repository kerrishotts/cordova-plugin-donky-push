//
//  DRIDataControllerHelper.h
//  RichInbox
//
//  Created by Chris Wunsch on 27/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DNRichMessage.h"
#import "DRIDataController.h"

@interface DRIDataControllerHelper : NSObject

+ (NSIndexPath *)handleRowSelectedState:(NSIndexPath *)indexPath richMessage:(DNRichMessage *)richMessage tableView:(UITableView *)tableView selectedMessages:(NSArray *)selectedMessages delegate:(id)delegate dataSource:(DRIDataController *)dataSource originnalIndexPath:(NSIndexPath *)originalIndexPath;

+ (DRITableViewCell *)attemptToSelectNextRow:(NSIndexPath *)indexPath fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController tableView:(UITableView *)tableView;

+ (NSIndexPath *)toggleSelectedCell:(DRITableViewCell *)cell tableView:(UITableView *)tableView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController dataSource:(DRIDataController *)controller delegate:(id <DRIDataControllerDelegate>)delegate originalIndexPath:(NSIndexPath *)originalIndexPath;

+ (CGFloat)sizeOfTableViewRowWithMessage:(DNRichMessage *)richMessage tableView:(UITableView *)tableView theme:(DRUITheme *)theme;

@end
