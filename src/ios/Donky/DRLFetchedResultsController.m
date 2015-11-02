//
//  DRLFetchedResultsController.m
//  RichInbox
//
//  Created by Chris Wunsch on 24/07/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "DRLFetchedResultsController.h"
#import "DNRichMessage.h"
#import "DNDataController.h"
#import "NSManagedObject+DNHelper.h"
#import "DNSystemHelpers.h"

@interface DRLFetchedResultsController ()
@property(nonatomic, strong) UITableView *tableView;
@end

@implementation DRLFetchedResultsController
- (instancetype)initWithTableView:(UITableView *)tableView {
    
    self = [super init];
    
    if (self) {
        
        [self setTableView:tableView];
        
    }

    return self;
}

-(NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController == nil) {

        NSFetchRequest *request = [DNRichMessage fetchRequestWithContext:[[DNDataController sharedInstance] mainContext]];
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sentTimestamp" ascending:NO]]];

        if ([self isSearching]) {
            [request setPredicate:[NSPredicate predicateWithFormat:@"messageDescription CONTAINS[cd] %@ || senderDisplayName CONTAINS[cd] %@", [self searchString], [self searchString]]];
        }

        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[DNDataController sharedInstance] mainContext] sectionNameKeyPath:nil cacheName:nil];
        [_fetchedResultsController setDelegate:self];

        NSError *error;
        if (![_fetchedResultsController performFetch:&error]) {
            NSLog(@"Problem fetching comments for request: %@\nError: %@", request, [error localizedDescription]);
        }
    }

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {

        case NSFetchedResultsChangeInsert: {
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            if ([[self delegate] respondsToSelector:@selector(insertRowsAtIndexPaths:)]) {
                [[self delegate] insertRowsAtIndexPaths:@[newIndexPath]];
            }
        }
            break;

        case NSFetchedResultsChangeDelete: {
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];

            if ([[self delegate] respondsToSelector:@selector(deleteRowsAtIndexPath:)]) {
                [[self delegate] deleteRowsAtIndexPath:indexPath];
            }
        }
            break;

        case NSFetchedResultsChangeUpdate: {

            if ([[self delegate] respondsToSelector:@selector(reloadRowsAtIndexPaths:)]) {
                [[self delegate] reloadRowsAtIndexPaths:@[indexPath]];
            }

            [[self tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;

        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] endUpdates];
}

@end
