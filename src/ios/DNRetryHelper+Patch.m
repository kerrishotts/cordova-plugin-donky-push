#import <objc/runtime.h>
#import "DNRetryHelper+Patch.h"
#import "DNLoggingController.h"
#import "DNNetworkController.h"

@implementation DNRetryHelper (Patch)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];

        SEL originalSelector = @selector(retryEvent:);
        SEL swizzledSelector = @selector(xxx_retryEvent:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)xxx_retryEvent:(DNRetryObject *)retryEvent {
    DNInfoLog(@"Retrying request %@", [[retryEvent request] route]);
    DNRequest *request = [retryEvent request];
    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:[request isSecure] route:[request route] httpMethod:[request method] parameters:[request parameters] success:^(NSURLSessionDataTask *task, id responseData) {
        [[self retriedRequests] removeObject:retryEvent];
        if ([request successBlock]) {
            [request successBlock](task, responseData);
        }
    } failure:[request failureBlock]];
}
@end