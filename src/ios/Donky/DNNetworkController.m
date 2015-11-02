//
//  DNNetworkController.m
//  Core SDK Container
//
//  Created by Chris Wunsch on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <dispatch/dispatch.h>
#import "DNNetworkController.h"
#import "DNSessionManager.h"
#import "DNDeviceConnectivityController.h"
#import "DNDataController.h"
#import "DNNetworkHelper.h"
#import "DNDonkyNetworkDetails.h"
#import "DNDonkyCore.h"
#import "DNConstants.h"
#import "DNLoggingController.h"
#import "DNErrorController.h"
#import "DNContentNotification.h"
#import "DNConfigurationController.h"
#import "DNAccountController.h"
#import "DNNetworkDataHelper.h"
#import "DNSignalRInterface.h"
#import "DNNetworkControllerQueue.h"

static NSString *const DNMaxTimeWithoutSynchronise = @"MaxMinutesWithoutNotificationExchange";

static NSString *const DNCustomType = @"customType";

@interface DNNetworkController ()

@property (nonatomic, strong) DNDeviceConnectivityController *deviceConnectivity;
@property (nonatomic, strong) DNNetworkControllerQueue *controllerQueue;
@property (nonatomic, strong) NSMutableArray *pendingContentNotifications;
@property (nonatomic, strong) NSMutableArray *pendingClientNotifications;
@property (nonatomic, strong) NSMutableArray *exchangeRequests;
@property (nonatomic, strong) NSMutableArray *queuedCalls;
@property (nonatomic, strong) DNRetryHelper *retryHelper;
@property (nonatomic, strong) NSTimer *synchroniseTimer;
@property (nonatomic, strong) NSDate *lastSynchronise;
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

dispatch_queue_t networkControllerQueue;

@implementation DNNetworkController

#pragma mark -
#pragma mark - Setup Singleton

+(DNNetworkController *)sharedInstance
{
    static DNNetworkController *sharedInstance = nil;
    static dispatch_once_t onceToken;

    @synchronized (sharedInstance) {
        dispatch_once(&onceToken, ^{
            sharedInstance = [[DNNetworkController alloc] initPrivate];
        });
    }

    return sharedInstance;
}

-(instancetype)init
{
    return [DNNetworkController sharedInstance];
}

-(instancetype)initPrivate
{
    self  = [super init];

    if (self)
    {

        if (!networkControllerQueue) {
            networkControllerQueue = dispatch_queue_create("com.donky.networkController", NULL);
        }
        
        [self setContext:[[DNDataController sharedInstance] mainContext]];

        [self setControllerQueue:[[DNNetworkControllerQueue alloc] init]];
        
        //Create the exchange request array:
        [self setExchangeRequests:[[NSMutableArray alloc] init]];
        [self setQueuedCalls:[[NSMutableArray alloc] init]];
        [self setPendingClientNotifications:[[NSMutableArray alloc] init]];
        [self setPendingContentNotifications:[[NSMutableArray alloc] init]];

        [self setRetryHelper:[[DNRetryHelper alloc] init]];
        [self initialisePendingNotifications];
        
        
    }

    return self;
}

- (void)initialisePendingNotifications {
    [[self pendingClientNotifications] addObjectsFromArray:[DNNetworkDataHelper clientNotificationsWithTempContext:[self context]]];
    [[self pendingContentNotifications] addObjectsFromArray:[DNNetworkDataHelper contentNotificationsWithTempContext:[self context]]];
}

- (void)startMinimumTimeForSynchroniseBuffer:(NSTimeInterval)buffer {

    if ([self synchroniseTimer]) {
        [[self synchroniseTimer] invalidate], [self setSynchroniseTimer:nil];
    }

    NSInteger maxTime = [[DNConfigurationController objectFromConfiguration:DNMaxTimeWithoutSynchronise] integerValue];
    if (maxTime > 0) {
        NSTimeInterval interval = (maxTime * 60) - buffer; //Convert to minutes
        if (interval < 0) {
            interval = 0; //Guard against 0 value
        }
        [self setSynchroniseTimer:[NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(syncFromTimer) userInfo:nil repeats:NO]];
        [[NSRunLoop mainRunLoop] addTimer:[self synchroniseTimer] forMode:NSDefaultRunLoopMode];
    }
}

#pragma mark -
#pragma mark - Network Calls:

- (void)performSecureDonkyNetworkCall:(BOOL)secure route:(NSString *)route httpMethod:(DonkyNetworkRoute)httpMethod parameters:(id)parameters success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    
    @try {
        
        __weak __typeof(self) weakSelf = self;
        
        dispatch_async(networkControllerQueue, ^{

            //We remove all non active tasks from the queue:
            [weakSelf removeAllCompletedTasksFromQueue];

            if (![self deviceConnectivity]) {
                [self setDeviceConnectivity:[[DNDeviceConnectivityController alloc] init]];
            }

            DNRequest *request = [[DNRequest alloc] initWithSecure:secure route:route httpMethod:httpMethod parameters:parameters success:successBlock failure:failureBlock];

            if ([[weakSelf deviceConnectivity] hasValidConnection]) {

                if (![DNDonkyNetworkDetails hasValidAccessToken] && secure) {
                    [DNNetworkHelper reAuthenticateWithRequest:request failure:failureBlock];
                    return;
                }

                //If we are suspended we simply bail out:
                if (secure && [DNDonkyNetworkDetails isSuspended]) {
                    if (failureBlock) {
                        failureBlock(nil, [DNErrorController errorCode:DNCoreSDKSuspendedUser userInfo:@{@"Reason" : @"User is suspended"}]);
                    }
                    return;
                }

                else if (![DNNetworkHelper isPerformingBlockingTask:[weakSelf exchangeRequests]]) {
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

                    //Create a new session manager:
                    DNSessionManager *sessionManager = [[DNSessionManager alloc] initWithSecureURl:secure];

                    //If request is nil then we bail out:
                    if (!request) {
                        DNErrorLog(@"there is no valid request object: %@\nBailing out ...", request);
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                        return;
                    }

                    NSURLSessionTask *currentTask = [DNNetworkHelper performNetworkTaskForRequest:request sessionManager:sessionManager success:^(NSURLSessionDataTask *task, id responseData) {
                            dispatch_async(networkControllerQueue, ^{
                                [weakSelf handleSuccess:responseData forTask:task request:request];
                            });
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        dispatch_async(networkControllerQueue, ^{
                            [weakSelf handleError:error task:task request:request];
                        });
                    }];

                    if (currentTask) {
                        [currentTask setTaskDescription:[request route]];
                        @synchronized ([self exchangeRequests]) {
                            [[self exchangeRequests] addObject:currentTask];
                        }
                    }
                }
                else {
                    //Do we have a duplicate task?
                    @synchronized ([self queuedCalls]) {
                        DNInfoLog(@"Donky is performing protected calls, your request will be performed immediately once these have finished...");
                        if (![[request route] isEqualToString:kDNNetworkAuthentication]) {
                            DNInfoLog(@"Saving Request: %@", [request route]);
                            [[self queuedCalls] addObject:request];
                        }
                    }
                }
            }
            else {
                [[self deviceConnectivity] addFailedRequestToQueue:request];
            }
        });
    }
    @catch (NSException *exception) {
        [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
        if (failureBlock) {
            failureBlock(nil, nil);
        }
    }
}

- (void)handleSuccess:(id)responseData forTask:(NSURLSessionDataTask *)task request:(DNRequest *)request {

    if ([request isSecure] && [DNAccountController isSuspended]) {
        [DNAccountController setIsSuspended:NO];
    }
    
    if ([DNNetworkHelper isPerformingBlockingTask:[@[task] mutableCopy]]) {
        DNSensitiveLog(@"Request %@ successful, response data = %@", [task taskDescription], responseData ?: @"");
    }
    else {
        DNInfoLog(@"Request %@ successful, response data = %@", [task taskDescription], responseData ?: @"");
    }
    
    [self removeTask:task];
    [self performNextTask];
    
    if ([request successBlock]) {
        [request successBlock](task, responseData);
    }
    else {
        DNInfoLog(@"No Completion block: %@", [request route]);
    }
}

- (void)performNextTask {
    DNRequest *nextRequest = [[self queuedCalls] firstObject];
    if (nextRequest) {
        [self performSecureDonkyNetworkCall:[nextRequest isSecure]
                                      route:[nextRequest route]
                                 httpMethod:[nextRequest method]
                                 parameters:[nextRequest parameters]
                                    success:[nextRequest successBlock]
                                    failure:[nextRequest failureBlock]];
        [[self queuedCalls] removeObject:nextRequest];
    }
    else {
        DNInfoLog(@"No more requests in the queue...");
    }
}

- (void)handleError:(NSError *)error task:(NSURLSessionDataTask *)task request:(DNRequest *)request {
    DNErrorLog(@"Network reponse error: %@", [error localizedDescription]);
    [self removeTask:task];
    
    dispatch_async(networkControllerQueue, ^{
        if (![DNErrorController serviceReturned:400 error:error] && ![DNErrorController serviceReturned:401 error:error] && ![DNErrorController serviceReturned:403 error:error] && ![DNErrorController serviceReturned:404 error:error])
            [[self retryHelper] retryRequest:request task:task];
        else if ([DNErrorController serviceReturned:401 error:error] && ![[request route] isEqualToString:kDNNetworkAuthentication]) {
            //Clear token:
            [DNDonkyNetworkDetails saveTokenExpiry:nil];
            [DNAccountController refreshAccessTokenSuccess:^(NSURLSessionDataTask *task2, id responseData2) {
                [[self retryHelper] retryRequest:request task:task];
            } failure:^(NSURLSessionDataTask *task2, NSError *error2) {
                if ([request failureBlock]) {
                    [request failureBlock](task2, error2);
                }
            }];
        }
        else {
            [DNNetworkHelper handleError:error task:task request:request];
        }
    });
}

- (void)serverNotificationForId:(NSString *)notificationID success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    NSString *getNotificationRoute = [NSString stringWithFormat:@"%@%@", kDNNetworkGetNotification, notificationID];
    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES route:getNotificationRoute httpMethod:DNGet parameters:nil success:^(NSURLSessionDataTask *task, id responseData) {
        dispatch_async(networkControllerQueue, ^{
            DNServerNotification *serverNotification = [[DNServerNotification alloc] initWithNotification:responseData];
            NSMutableDictionary *notifications = [[NSMutableDictionary alloc] init];
            notifications[[serverNotification notificationType]] = @[serverNotification];
            [[DNDonkyCore sharedInstance] notificationsReceived:notifications];
            if (successBlock) {
                successBlock(task, serverNotification);
            }
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DNErrorLog(@"%@", [error localizedDescription]);
        if (failureBlock) {
            failureBlock(task, error);
        }
    }];
}

- (void)allServerNotificationsSuccess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES route:kDNNetworkGetNotification httpMethod:DNGet parameters:nil success:^(NSURLSessionDataTask *task, id responseData) {
        [self processNotificationResponse:@{@"serverNotifications" : responseData} task:task success:nil failure:nil];
        if (successBlock) {
            successBlock(task, responseData);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DNErrorLog(@"%@", [error localizedDescription]);
        if (failureBlock) {
            failureBlock(task, error);
        }
    }];
}

- (void)syncFromTimer {
    //Check last sync:
    NSTimeInterval timeSinceSync = [[NSDate date] timeIntervalSinceDate:[self lastSynchronise]];
    if (timeSinceSync >= (60 * [[DNConfigurationController objectFromConfiguration:DNMaxTimeWithoutSynchronise] integerValue])) {
        [self synchronise];
    }
    else {
        [self startMinimumTimeForSynchroniseBuffer:timeSinceSync];
    }
}

- (void)synchronise {
    [self synchroniseSuccess:nil failure:nil];
}

- (void)synchroniseSuccess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    @try {
        dispatch_async(networkControllerQueue, ^{
            if (![self synchroniseTimer]) {
                [self startMinimumTimeForSynchroniseBuffer:0];
            }

            //Set the last sync date
            [self setLastSynchronise:[NSDate date]];

            //Update the timer as the current timer now has an invalid time.
            [self synchroniseTimer];

            //Remove completed tasks:
            [self removeAllCompletedTasksFromQueue];
            
            //Publish:
            @synchronized ([self pendingClientNotifications]) {
                [[self pendingClientNotifications] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if (![obj isKindOfClass:[DNClientNotification class]]) {
                        DNErrorLog(@"Whoops, something has gone wrong, expected class DNClientNotification. Got %@", NSStringFromClass([obj class]));
                    }
                    else {
                        DNClientNotification *notification = obj;
                        [[DNDonkyCore sharedInstance] publishOutboundNotification:[notification notificationType] data:notification];
                    }
                }];
            }

            @synchronized ([self pendingContentNotifications]) {
                [[self pendingContentNotifications] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if (![obj isKindOfClass:[DNContentNotification class]]) {
                        DNErrorLog(@"Whoops, something has gone wrong, expected class DNContentNotification. Got %@", NSStringFromClass([obj class]));
                    }
                    else {
                        DNContentNotification *notification = obj;
                        NSString *type = [notification content][DNCustomType];
                        [[DNDonkyCore sharedInstance] publishOutboundNotification:type data:notification];
                    }
                }];
            }

            //This is where duff notifications should be trimmed out
            NSMutableDictionary *params = [DNNetworkDataHelper networkClientNotifications:[self pendingClientNotifications]
                                                              networkContentNotifications:[self pendingContentNotifications]
                                                                              tempContext:YES];
            NSArray *sentClientNotifications = [DNNetworkHelper clientNotifications:[self pendingClientNotifications]];
            NSArray *sentContentNotifications = [DNNetworkHelper contentNotifications:[self pendingContentNotifications]];
            
            if ([DNSignalRInterface signalRServiceIsReady]) {
                [[self controllerQueue] sendData:params completion:^(id response, NSError *error) {
                    if (!error) {
                        @try {
                            [self cleanUpClientNotifications:sentClientNotifications contentNotifications:sentContentNotifications];
                            [self processNotificationResponse:response task:nil success:successBlock failure:failureBlock];
                        }
                        @catch (NSException *exception) {
                            DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
                            [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (failureBlock) {
                                    failureBlock(nil, nil);
                                }
                            });
                        }
                    }
                    else {
                        [DNNetworkDataHelper saveClientNotificationsToStore:sentClientNotifications];
                        [DNNetworkDataHelper saveClientNotificationsToStore:sentContentNotifications];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (failureBlock) {
                                failureBlock(nil, error);
                            }
                        });
                    }
                }];
            }

            else {
                if ([[self controllerQueue] synchroniseWithParams:params successBlock:^(NSURLSessionDataTask *task, id responseData) {
                    @try {
                        [self cleanUpClientNotifications:sentClientNotifications contentNotifications:sentContentNotifications];
                        [self processNotificationResponse:responseData task:nil success:successBlock failure:failureBlock];
                    }
                    @catch (NSException *exception) {
                        DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
                        [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (failureBlock) {
                                failureBlock(nil, nil);
                            }
                        });
                    }

                } failureBlock:^(NSURLSessionDataTask *task, NSError *error) {
                    //Save data:
                    [DNNetworkDataHelper saveClientNotificationsToStore:sentClientNotifications];
                    [DNNetworkDataHelper saveClientNotificationsToStore:sentContentNotifications];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (failureBlock) {
                            failureBlock(task, error);
                        }
                    });
                }]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (failureBlock) {
                            failureBlock(nil, [DNErrorController errorWithCode:DNCoreSDKErrorDuplicateSynchronise]);
                        }
                    });
                }
            }
        });
    }

    @catch (NSException *exception) {
        [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failureBlock) {
                failureBlock(nil, nil);
            }
        });
    }
}

- (void)cleanUpClientNotifications:(NSArray *)clientNotifications contentNotifications:(NSArray *)contentNotifications {
    
    //We need to clear out these types:
    if ([clientNotifications count]) {
        [DNNetworkDataHelper deleteNotifications:clientNotifications];
    }
    if ([contentNotifications count]) {
        [DNNetworkDataHelper deleteNotifications:contentNotifications];
    }

    @synchronized([self pendingClientNotifications]) {
        [[self pendingClientNotifications] removeObjectsInArray:clientNotifications];
    }
    
    @synchronized([self pendingContentNotifications]) {
        [[self pendingContentNotifications] removeObjectsInArray:contentNotifications];
    }
}

- (void)processNotificationResponse:(id)responseData task:(NSURLSessionDataTask *)task success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    [self removeAllCompletedTasksFromQueue];
    [DNNetworkHelper processNotificationResponse:responseData
                                            task:task
                      pendingClientNotifications:[self pendingClientNotifications]
                     pendingContentNotifications:[self pendingContentNotifications]
                                         success:successBlock
                                         failure:failureBlock];
}

- (NSError *)sendContentNotifications:(NSArray *)notifications success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    NSError *error = [self queueContentNotifications:notifications];
    [self synchroniseSuccess:successBlock failure:failureBlock];
    return error;
}

#pragma mark -
#pragma mark - Notifications

- (void)queueClientNotifications:(NSArray *)notifications {
    [DNNetworkHelper queueClientNotifications:notifications pendingNotifications:[self pendingClientNotifications]];
}

- (NSError *)queueContentNotifications:(NSArray *)notifications {
    return [DNNetworkHelper queueContentNotifications:notifications pendingNotifications:[self pendingContentNotifications]];
}

#pragma mark -
#pragma mark - Network Task Manager

- (void)removeTask:(NSURLSessionTask *)task {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if ([task state] == NSURLSessionTaskStateCompleted) {
        DNInfoLog(@"Clearing completed task: %@", [task taskDescription]);
        @synchronized ([self exchangeRequests]) {
            [[self exchangeRequests] removeObject:task];
        }
    }
}

- (void)removeAllCompletedTasksFromQueue {
    NSMutableArray *tasksToClear = [[NSMutableArray alloc] init];
    //Clear completed tasks:
    @synchronized ([self exchangeRequests]) {
        [[self exchangeRequests] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSURLSessionDataTask *task = obj;
            if ([task state] != NSURLSessionTaskStateRunning) {
                [tasksToClear addObject:task];
            }
        }];
        if ([tasksToClear count]) {
            DNInfoLog(@"Removing all non running tasks: %@", tasksToClear);
            [[self exchangeRequests] removeObjectsInArray:tasksToClear];
        }
    }
}

@end
