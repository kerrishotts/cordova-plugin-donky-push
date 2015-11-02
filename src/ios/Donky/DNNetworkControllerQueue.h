//
//  DNNetworkControllerQueue.h
//  ChatUI
//
//  Created by Chris Wunsch on 24/09/2015.
//  Copyright © 2015 Chris Wunsch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNBlockDefinitions.h"

@interface DNNetworkControllerQueue : NSOperationQueue

- (BOOL)synchroniseWithParams:(NSDictionary *)params successBlock:(DNNetworkSuccessBlock)success failureBlock:(DNNetworkFailureBlock)failure;

- (void)sendData:(NSDictionary *)params completion:(DNSignalRCompletionBlock) completion;

@end
