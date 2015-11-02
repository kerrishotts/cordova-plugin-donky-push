//
//  DNDataController.h
//  NAAS Core SDK Container
//
//  Created by Chris Wunsch on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DNUserDetails.h"
#import "DNDeviceUser.h"

@interface DNDataController : NSObject

/*!
 The main context that is used for managing all managed objects in the Donky SDK.
 
 @since 2.0.0.0
 */
@property (nonatomic, strong, readonly) NSManagedObjectContext *mainContext;

/*!
 The persistent store coordinator for the Core Data model used in the Donky SDK.
 
 @since 2.0.0.0
 */
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/*!
 The shared instance that should be used to access all methods and properties of the
 DNDataController.
 
 @return the shared static instance.
 
 @since 2.0.0.0
 */
+ (DNDataController *)sharedInstance;

+ (NSManagedObjectContext *)temporaryContext;

/*!
 Helper method to save all the pending data transactions in the main context.
 
 @since 2.0.0.0
 */
- (void)saveAllData;

- (void)saveContext:(NSManagedObjectContext *)context;

@end