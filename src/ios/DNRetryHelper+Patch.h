#import "DNRetryHelper.h"
#import "DNRetryObject.h"

@interface DNRetryHelper (Patch)

- (void)retryEvent:(DNRetryObject *)retryEvent;
- (void)xxx_retryEvent:(DNRetryObject *)retryEvent;
@property(nonatomic, strong) NSMutableArray *retriedRequests;

@end