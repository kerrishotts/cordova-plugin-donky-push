#import "AppDelegate+Donky.h"
#import <objc/runtime.h>
#import "DNDonkyCore.h"
#import "DPUINotificationController+Extended.h"
#import "DCAAnalyticsController.h"
#import "DonkyPlugin.h"
#import "DCMConstants.h"

@implementation AppDelegate (Donky)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];

        SEL originalSelector = @selector(application:didFinishLaunchingWithOptions:);
        SEL swizzledSelector = @selector(xxx_application:didFinishLaunchingWithOptions:);
        
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

- (BOOL) xxx_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"AppDelegate(Donky):didFinishLaunchingWithOptions");
    if([self respondsToSelector:@selector(beforeInitDonky)]){
        [self beforeInitDonky];
    }
    
    // Add support for deep links
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyEventNotificationTapped handler:^(DNLocalEvent *event) {
        NSDictionary *eventData = [event data];
        NSDictionary *userTapped = eventData[@"UserTapped"];
        NSDictionary *buttonAction = userTapped[@"ButtonAction"];
        
        if([buttonAction[@"actionType"] isEqualToString:@"DeepLink"])
        {
            NSString *linkValue = buttonAction[@"data"];
            [self handleDeepLink:linkValue];
        }
    }];
    
    [self initDonky];
    return [self xxx_application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)handleDeepLink:(NSString*)linkValue
{
    if(linkValue != nil && ![linkValue isKindOfClass:[NSNull class]])
    {
        if([self respondsToSelector:@selector(didReceiveLinkFromInteractiveNotification:)])
        {
            NSLog(@"Calling didReceiveLinkFromInteractiveNotification with value: %@", linkValue);
            [self didReceiveLinkFromInteractiveNotification:linkValue];
        }
        else
        {
            NSLog(@"AppDelegate does not implement didReceiveLinkFromInteractiveNotification so link will not be processed.");
        }
    }
}

- (void)initDonky;
{
    NSLog(@"AppDelegate(Donky):initDonky");
    
    NSLog(@"Start Donky analytics controller");
    [[DCAAnalyticsController sharedInstance] start];
    
    NSLog(@"Start Donky push UI controller");
    [[DPUINotificationControllerExtended sharedInstance] start];
    
    NSString* apiKey = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"DonkyApiKey"] objectAtIndex:0];
    
    NSLog(@"Start Donky Core with API key: %@", apiKey);
    
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:apiKey succcess:^(NSURLSessionDataTask *task, id responseData) {
        NSLog(@"Donky Core initialisation complete");
        [DonkyPlugin sdkIsReady:nil];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error initialising Donky Core: %@", error.localizedDescription);
        [DonkyPlugin sdkIsReady:error.localizedDescription];
    }];
}

@end