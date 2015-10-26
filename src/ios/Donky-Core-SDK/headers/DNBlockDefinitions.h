//
//  DKBlockDefinitions.h
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 18/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNLocalEvent.h"

/*!
 Success block definition used for all methods that perform a network call.
 
 @param task         the network task created for this operation.
 @param responseData the data sent back from the operation.
 
 @since 2.0.0.0
 */
typedef void (^DNNetworkSuccessBlock) (NSURLSessionDataTask *task, id responseData);

/*!
  Failure block used for all methods that perform a network call.
 
 @param task         the network task created for this operation.
 @param error        the NSError object containing the failure details.
 
 @since 2.0.0.0
 */
typedef void (^DNNetworkFailureBlock) (NSURLSessionDataTask *task, NSError *error);

/*!
 The block definition used for Local events.
 
 @since 2.0.0.0
 */
typedef void (^DNLocalEventHandler) (DNLocalEvent * event);