#import "DonkyPlugin.h"
#import "DNAccountController.h"
#import "DNContentNotification.h"
#import "DNNetworkController.h"
#import "DNSubscription.h"
#import "DNServerNotification.h"
#import <objc/runtime.h>


BOOL debugEnabled = TRUE;
#define DLog(fmt, ...) { \
if (debugEnabled) \
NSLog((@"DonkyPlugin: " fmt), ##__VA_ARGS__); \
}

@implementation DonkyPlugin

@synthesize cordova_command;
@synthesize moduleDefinition;

static UIWebView* webView;

static bool sdkInitialised = false;
static bool sdkInitSuccess;
static bool cordovaInitialised = false;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];
        
        SEL originalSelector = @selector(initWithWebView:);
        SEL swizzledSelector = @selector(xxx_initWithWebView:);
        
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

- (CDVPlugin*)xxx_initWithWebView:(UIWebView*)theWebView
{
    NSLog(@"DonkyPlugin:initWithWebView");
    CDVPlugin* this = [self xxx_initWithWebView:theWebView];
    
    cordovaInitialised = true;
    webView = theWebView;
    if(sdkInitialised){
        NSLog(@"Donky SDK ready before Cordova");
        [[self class] notifySdkIsReady];
    }
    return this;
}

+ (void) sdkIsReady:(bool)success
{
    NSLog(@"DonkyPlugin:sdkIsReady");
    sdkInitialised = true;
    sdkInitSuccess = success;
    if(cordovaInitialised){
        NSLog(@"Donky SDK ready after Cordova");
        [self notifySdkIsReady];
    }
}

+ (void) notifySdkIsReady;
{
    NSString* successString;
    if(sdkInitSuccess){
        successString = @"true";
    }else{
        successString = @"false";
    }
    NSString* jsString = [NSString stringWithFormat:@"document.donkyready('%@')", successString];
    [webView stringByEvaluatingJavaScriptFromString:jsString];
}

- (void) init:(CDVInvokedUrlCommand*)command;
{
    NSLog(@"DonkyPlugin:init");
}

- (void) updateUserDetails:(CDVInvokedUrlCommand*)command;
{
    self.cordova_command = command;
    
    @try {
        DLog(@"Updating user details");
        NSString* jUserDetails = [command.arguments objectAtIndex:0];
    
        if([jUserDetails isEqual:[NSNull null]]){
            [NSException raise:@"User details not specified" format:@"User details not specified"];
        }
        DNUserDetails* userDetails = [self getUserDetailsFromJson:jUserDetails];
        
        [DNAccountController updateUserDetails:userDetails success:^(NSURLSessionDataTask *task, id responseData) {
            DLog(@"Successfully updated user details");
          [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"Failed to update user details with error: %@", error.localizedDescription);
            [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription]];
        }];
    }
    @catch (NSException *exception) {
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason]];
    }
}

- (void) updateDeviceDetails:(CDVInvokedUrlCommand*)command;
{
    self.cordova_command = command;
    
    @try {
        DLog(@"Updating device details");
        NSString* jDeviceDetails = [command.arguments objectAtIndex:0];
    
        if([jDeviceDetails isEqual:[NSNull null]]){
            [NSException raise:@"Device details not specified" format:@"Device details not specified"];
        }
        DNDeviceDetails* deviceDetails = [self getDeviceDetailsFromJson:jDeviceDetails];
        
        [DNAccountController updateDeviceDetails:deviceDetails success:^(NSURLSessionDataTask *task, id responseData) {
            DLog(@"Successfully updated device details");
          [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"Failed to update device details with error: %@", error.localizedDescription);
          [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription]];
        }];
    }
    @catch (NSException *exception) {
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason]];
    }
}

- (void) updateRegistrationDetails:(CDVInvokedUrlCommand*)command;
{
    self.cordova_command = command;
    
    @try {
        DLog(@"Updating registration details");
        NSString* jUserDetails = [command.arguments objectAtIndex:0];
        if([jUserDetails isEqual:[NSNull null]]){
            [NSException raise:@"User details not specified" format:@"User details not specified"];
        }
        DNUserDetails* userDetails = [self getUserDetailsFromJson:jUserDetails];
        
        NSString* jDeviceDetails = [command.arguments objectAtIndex:1];
        if([jDeviceDetails isEqual:[NSNull null]]){
            [NSException raise:@"Device details not specified" format:@"Device details not specified"];
        }
        DNDeviceDetails* deviceDetails = [self getDeviceDetailsFromJson:jDeviceDetails];
        
        [DNAccountController updateRegistrationDetails:userDetails deviceDetails:deviceDetails success:^(NSURLSessionDataTask *task, id responseData) {
            DLog(@"Successfully updated registration details");
          [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"Failed to update registration details with error: %@", error.localizedDescription);
          [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription]];
        }];
    }
    @catch (NSException *exception) {
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason]];
    }
}

- (void) replaceRegistrationDetails:(CDVInvokedUrlCommand*)command;
{
    self.cordova_command = command;
    
    @try {
        DLog(@"Replacing registration details");
        NSString* jUserDetails = [command.arguments objectAtIndex:0];
        if([jUserDetails isEqual:[NSNull null]]){
            [NSException raise:@"User details not specified" format:@"User details not specified"];
        }
        DNUserDetails* userDetails = [self getUserDetailsFromJson:jUserDetails];
        
        NSString* jDeviceDetails = [command.arguments objectAtIndex:1];
        if([jDeviceDetails isEqual:[NSNull null]]){
            [NSException raise:@"Device details not specified" format:@"Device details not specified"];
        }
        DNDeviceDetails* deviceDetails = [self getDeviceDetailsFromJson:jDeviceDetails];
        
        [DNAccountController replaceRegistrationDetailsWithUserDetails:userDetails deviceDetails:deviceDetails success:^(NSURLSessionDataTask *task, id responseData) {
            DLog(@"Successfully replaced registration details");
          [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"Failed to replace registration details with error: %@", error.localizedDescription);
          [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription]];
        }];
    }
    @catch (NSException *exception) {
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason]];
    }
}

- (void) sendContentNotificationToUser:(CDVInvokedUrlCommand*)command;
{
    self.cordova_command = command;
    
    @try {
        DLog(@"Sending content notification to user");
        NSString* userId = [command.arguments objectAtIndex:0];
        NSString* notificationType = [command.arguments objectAtIndex:1];
        NSString* jsData = [command.arguments objectAtIndex:2];
        BOOL queue = [[command argumentAtIndex:2] boolValue];
        
        NSArray* data = [self jsonStringToArray:jsData];
        
        DNContentNotification* contentNotification = [[DNContentNotification alloc] initWithUsers:@[userId] customType:notificationType data:data];
        if(queue){
            [self sendContentNotification:contentNotification];
        }else{
            [self queueContentNotification:contentNotification];
        }
       
    }
    @catch (NSException *exception) {
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason]];
    }
}

- (void) sendContentNotificationToUsers:(CDVInvokedUrlCommand*)command;
{
    self.cordova_command = command;
    
    @try {
        DLog(@"Sending content notification to users");
        NSString* jsUsers = [command.arguments objectAtIndex:0];
        NSString* notificationType = [command.arguments objectAtIndex:1];
        NSString* jsData = [command.arguments objectAtIndex:2];
        BOOL queue = [[command argumentAtIndex:2] boolValue];
        
        NSArray* users = [self jsonStringToArray:jsUsers];
        NSArray* data = [self jsonStringToArray:jsData];
        
        DNContentNotification* contentNotification = [[DNContentNotification alloc] initWithUsers:users customType:notificationType data:data];
        if(queue){
            [self sendContentNotification:contentNotification];
        }else{
            [self queueContentNotification:contentNotification];
        }
        
    }
    @catch (NSException *exception) {
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason]];
    }
}

- (void) synchronise:(CDVInvokedUrlCommand*)command;
{
    self.cordova_command = command;
    
    @try {
        DLog(@"Synchronising");
        [[DNNetworkController sharedInstance] synchroniseSuccess:^(NSURLSessionDataTask *task, id responseData) {
            DLog(@"Successfully synchronised");
            [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"Failed to synchronise with error: %@", error.localizedDescription);
            [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription]];
        }];
    }
    @catch (NSException *exception) {
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason]];
    }
}

- (void) subscribeToContentNotifications:(CDVInvokedUrlCommand*)command;
{
    self.cordova_command = command;
    
    @try {
        DLog(@"Subscribing to notifications");
        NSString* notificationType = [command.arguments objectAtIndex:0];
        DNSubscription* subscription = [[DNSubscription alloc] initWithNotificationType:notificationType handler:^(id responseData) {
            @try {
                DNServerNotification* serverNotification = (DNServerNotification*) responseData;

                NSError* err = nil;
                NSData* jsonData = [NSJSONSerialization dataWithJSONObject:serverNotification.data options:0 error:&err]; 
                if(err == nil){
                    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [self jsNotificationCallback:jsonString:notificationType];
                }else{
                    [self jsNotificationCallback:err.localizedDescription:notificationType];
                }
            }@catch (NSException* exception) {
                [self jsNotificationCallback:exception.reason:notificationType];
            }
        }];
        [[DNDonkyCore sharedInstance] subscribeToContentNotifications:self.moduleDefinition subscriptions:@[subscription]];
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]];
    }
    @catch (NSException* exception) {
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason]];
    }
}

/*
 * Helpers
 */
- (void) jsNotificationCallback:(NSString*)jsData:(NSString*)notificationType;
{
    NSString* jsString = [NSString stringWithFormat:@"cordova.plugins.donky.core._notificationTypeCallbacks[\"%@\"](%@);", notificationType, jsData];
    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
}

- (void) onInitSuccess;
{
    [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]];
    self.moduleDefinition = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.0"];
}
 
- (void) sendContentNotification:(DNContentNotification*)contentNotification;
{
    [[DNNetworkController sharedInstance] sendContentNotifications:@[contentNotification] success:^(NSURLSessionDataTask *task, id responseData) {
        DLog(@"Successfully sent content notification");
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Failed to send content notification with error: %@", error.localizedDescription);
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription]];
    }];
}

- (void) queueContentNotification:(DNContentNotification*)contentNotification;
{
    [[DNNetworkController sharedInstance] queueContentNotifications:@[contentNotification]];
    DLog(@"Successfully queued content notification");
    [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]];
}

- (DNUserDetails*) getUserDetailsFromJson:(NSString*)json;
{
    NSArray* oUserDetails = [self jsonStringToArray:json];
    NSString* userId = nil;
    NSString* displayName = nil;
    NSString* emailAddress = nil;
    NSString* mobileNumber = nil;
    NSString* countryCode = nil;
    NSString* firstName = nil;
    NSString* lastName = nil;
    NSString* avatarId = nil;
    NSArray* selectedTags = nil;
    NSDictionary* additionalProperties = nil;
    
    if([oUserDetails valueForKey:@"userId"] != NULL){
       userId = [oUserDetails valueForKey:@"userId"];
    }
    if([oUserDetails valueForKey:@"displayName"] != NULL){
       displayName = [oUserDetails valueForKey:@"displayName"];
    }
    if([oUserDetails valueForKey:@"emailAddress"] != NULL){
       emailAddress = [oUserDetails valueForKey:@"emailAddress"];
    }
    if([oUserDetails valueForKey:@"mobileNumber"] != NULL){
       mobileNumber = [oUserDetails valueForKey:@"mobileNumber"];
    }
    if([oUserDetails valueForKey:@"countryCode"] != NULL){
       countryCode = [oUserDetails valueForKey:@"countryCode"];
    }
    if([oUserDetails valueForKey:@"firstName"] != NULL){
       firstName = [oUserDetails valueForKey:@"firstName"];
    }
    if([oUserDetails valueForKey:@"lastName"] != NULL){
       lastName = [oUserDetails valueForKey:@"lastName"];
    }
    if([oUserDetails valueForKey:@"avatarId"] != NULL){
       avatarId = [oUserDetails valueForKey:@"avatarId"];
    }
    if([oUserDetails valueForKey:@"selectedTags"] != NULL){
       selectedTags = [oUserDetails valueForKey:@"selectedTags"];
    }
    if([oUserDetails valueForKey:@"additionalProperties"] != NULL){
       additionalProperties = [oUserDetails valueForKey:@"additionalProperties"];
    }
    
    DNUserDetails* userDetails = [[DNUserDetails alloc]
                   initWithUserID:userId
                   displayName:displayName
                   emailAddress:emailAddress
                   mobileNumber:mobileNumber
                   countryCode:countryCode
                   firstName:firstName
                   lastName:lastName
                   avatarID:avatarId
                   selectedTags:selectedTags
                   additionalProperties:additionalProperties
                   ];
    
    return userDetails;
}

- (DNDeviceDetails*) getDeviceDetailsFromJson:(NSString*)json;
{
    NSArray* oDeviceDetails = [self jsonStringToArray:json];
    NSString* deviceType = nil;
    NSString* deviceName = nil;
    NSDictionary* additionalProperties = nil;
    
    if([oDeviceDetails valueForKey:@"deviceType"] != NULL){
        deviceType = [oDeviceDetails valueForKey:@"deviceType"];
    }
    if([oDeviceDetails valueForKey:@"deviceName"] != NULL){
        deviceName = [oDeviceDetails valueForKey:@"deviceName"];
    }
    if([oDeviceDetails valueForKey:@"additionalProperties"] != NULL){
        additionalProperties = [oDeviceDetails valueForKey:@"additionalProperties"];
    }
    
    DNDeviceDetails* deviceDetails = [[DNDeviceDetails alloc]
                     initWithDeviceType:deviceType
                     name:deviceName
                     additionalProperties:additionalProperties
                     ];
    return deviceDetails;
}

- (void) sendPluginResult:(CDVPluginResult*)pluginResult;
{
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.cordova_command.callbackId];
}

- (NSArray*) jsonStringToArray:jsonStr
{
    NSArray* jsonObject = [NSJSONSerialization 
        JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
        options:0 error:NULL];
    return jsonObject;
}

@end