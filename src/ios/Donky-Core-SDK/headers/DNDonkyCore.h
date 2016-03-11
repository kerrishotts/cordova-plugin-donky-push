//
//  DNDonkyCore.h
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 18/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DNBlockDefinitions.h"
#import "DNDeviceDetails.h"
#import "DNServerNotification.h"
#import "DNModuleDefinition.h"
#import "DNSubscription.h"
#import "DNRegisteredServices.h"
#import "DNLocalEvent.h"
#import "DNUserDetails.h"

/*!
 Central Donky SDK controller class. This is responsible for initialisation, managing SDK state and maintaining a
 reference against Notification Modules, Event Modules and outbound notification modules.
 */
@interface DNDonkyCore : NSObject

#pragma mark - Class Properties

/*!
 Optional property, set this to your applications root window. Most of the time it is not necessary to do this and is
 only necessary if you are using an UI Modules. Some Donky UI modules present UI components, to do this the Donky SDK
 gets the 'window' property from the [UIApplication sharedApplication] singleton. In the case of Hybrid app development
 (Seattle Clouds etc...) the window property is never set and sometimes the window property is not declared in the AppDelegate.h.
 In this event the Donky SDK cannot present these view components. It is recommended therefore that you set this property to the appropriate window.
 
 @since 2.0.0.0
 */
@property (nonatomic, strong) UIWindow *applicationWindow;

/*!
 A boolean to dictate whether the Donky SDK should display the New Device alert automatically. To be alerted when a new device 
 message has been received, subscribe to the local event: kDNDonkyNotificationNewDeviceMessage
 
 @since 2.4.3.1
 */
@property (nonatomic, getter=shouldDisplayNewDeviceAlert) BOOL displayNewDeviceAlert;

/*!
 A boolean to dictate whether the Donky SDK should control the badge count. Please see documentation
 at http://docs.mobiledonky.com
 for more information.
 
 @since 2.4.3.1
 */
@property (nonatomic, getter=useDonkyBadgeCounts) BOOL donkyBadgeCounts;

/*!
 The block to be called when the SDK needs to refresh it's authentication token or when it
 gets an authentication challenge from the network.
 
 @since 2.7.1.3
 */
@property (nonatomic, copy) DNAuthenticationHandler authenticationHandler;

/*!
 A boolean to determine whether the SDK is in an authenticated state.
 
 @since 2.7.1.3
 */
@property (nonatomic, readonly, getter=isUsingAuth) BOOL usingAuth;

#pragma mark - Class Methods

/*!
 Singleton instance for the Donky Core.
 
 @return the current DNDonkyCore instance.
 */
+ (DNDonkyCore *)sharedInstance;

/*!
 The most basic SDK initialisation method. Use this method for quick, basic initialisation.
 
 @param apiKey the API key for the App Space where this device should be registered.
 
 @since 2.0.0.0
 */
- (void)initialiseWithAPIKey:(NSString *)apiKey;

/*!
 Initialisation method to start the SDK and preventing it from registering a new anonymous user (if no valid registration is found).
 
 @param apiKey the API key for the App Space where this device should be registered.
 
 @since 2.7.1.3
 */
- (void)initialiseWithoutRegistrationAPIKey:(NSString *)apiKey;

/*!
 The most basic SDK initialisation and the recommended path but also provides completion handlers.
 
 @param apiKey       the API key for the app space where the device should be registered.
 @param successBlock block that is called when the initialisation is successful.
 @param failureBlock block that is called when the initialisation fails.
 
 @since 2.6.5.4
 */
- (void)initialiseWithAPIKey:(NSString *)apiKey succcess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
  Initialisation method to start the SDK and preventing it from registering a new anonymous user (if no valid registration is found).
 
 @param apiKey       the API key for the app space where the device should be registered.
 @param successBlock block that is called when the initialisation is successful.
 @param failureBlock block that is called when the initialisation fails.

 @since 2.7.1.3
 */
- (void)initialiseWithoutRegistrationAPIKey:(NSString *)apiKey succcess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 The most basic initialisation method used when starting the SDK in an authenticated state.
 
 @param apiKey the API key to initialise with.
 
 @since 2.7.1.3
 */
- (void)authenticatedInitialiseWithAPIKey:(NSString *)apiKey;

/*!
 Initialise the SDK in an authenticated state but also 'autoRegister' if the 'authenticationHandler' on DNDonkyCore.h is set BEFORE
 initialisation is called.
 
 @param apiKey       the API key for the app space where the device should be registered.
 @param autoRegister whether the SDK should automatically register.
 
 @since 2.7.1.3
 */
- (void)authenticatedInitialiseWithAPIKey:(NSString *)apiKey autoRegister:(BOOL)autoRegister;

/*!
 Initiliase the SDK in an authenticated state, this API allows you to set a success and failure call back handler.
 
 @param apiKey       the API key for the app space where the device should be registered.
 @param autoRegister whether the SDK should automatically register.
 @param successBlock block that is called when the initialisation is successful, registration may NOT have finished at this point.
 @param failureBlock block that is called when the initialisation fails, registration may NOT have finished at this point.
 
 @since 2.7.1.3
 */
- (void)authenticatedInitialiseWithAPIKey:(NSString *)apiKey autoRegister:(BOOL)autoRegister success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
  SDK Initialisation method that allows a user to be provided for registration. Use this method to create a 'known registration'
  upon initialisation. It also allows for success and failure call back blocks to be set.
 
 @param apiKey       the API Key for the app space where this device should be registered.
 @param userDetails  the user details that should be used for a new registration.
 @param successBlock block that is called when the initialisation is successful.
 @param failureBlock block that is called when the initialisation fails.
 
 @since 2.0.0.0
 */
- (void)initialiseWithAPIKey:(NSString *)apiKey userDetails:(DNUserDetails *)userDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;;

/*!
 The full initialisation method for the SDK. Allows for a device user and device details object to be provided as part
 of the initialisation/registration process.
 
 @param apiKey        the API key for the App Space where this device should be registered.
 @param userDetails   a DNUserDetails object containing the details of the user that should be registered with this device.
 @param deviceDetails a DNDeviceDetails object containing detailed properties about the device.
 @param successBlock  block that is called when the initialisation is successful.
 @param failureBlock  block that is called when the initialisation fails, a detailed reason for the error will be
                      automatically rendered in the console and saved to the Debug Logs.
 
 @see DNUserDetails
 @see DNDeviceDetails
 
 @since 2.0.0.0
 */
- (void)initialiseWithAPIKey:(NSString *)apiKey userDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 Method to allow a class to register for and receive local events. Events can be published through a different API.
 
 @param localEvents an array of DNLocalEvent objects.
 
 @see DNLocalEvent
 
 @since 2.0.0.0
 */
- (void)subscribeToLocalEvent:(NSString *)eventType handler:(DNLocalEventHandler)eventHandler;

/*!
 Method to allow a class to un register for local events.
 
 @param localEvents an array of DNLocalEvent objects.
 
  @see DNLocalEvent
 
 @since 2.0.0.0
 */
- (void)unSubscribeToLocalEvent:(NSString *)eventType handler:(DNLocalEventHandler)handler;

/*!
 Method used to publish an event and send data to classes that are listening for this type of event.
 
 @param event the event type to trigger.
 @param data  the data to be passed to the listening class.
 
 @since 2.0.0.0
 */
- (void)publishEvent:(DNLocalEvent *)event;

/*!
 Method used to store a DNSubscriber object so that it can be receive data from the network.
 
 @param moduleDefinition        the DNModuleDefinition for the receiving class.
 @param subscriptions           an array of DNSubscription objects.
 
 @see DNModuleDefinition
 
 @since 2.0.0.0
 */
- (void)subscribeToContentNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions;

/*!
 Method used to un-subscribe a module from receiving specific notifications from the network..
 
 @param moduleDefinition        the DNModuleDefinition for the receiving class.
 @param subscriptions           an array of DNSubscription objects.
 
 @see DNModuleDefinition
 
 @since 2.0.0.0
 */
- (void)unSubscribeToContentNotifications:(DNModuleDefinition *)moduleDefinition subsciptions:(NSArray *)subscriptions;

/*!
 Method to subscribe a class to receive an event when an notification was sent to the network.
 
 @param moduleDefinition        the DNModuleDefinition that is interested in receiving the events.
 @param subscriptions           an array of DNSubscription objects.
 
 @see DNModuleDefinition
 
 @since 2.0.0.0
 */
- (void)subscribeToOutboundNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions;

/*!
 Method to un-subscribe a class from receiving events when particular notifications are being sent to the network.
 
 @param moduleDefinition        the module that no longer wishes to receive the events.
 @param subscriptions           the subscriptions it is no longer interested in.
 
 @since 2.0.0.0
 */
- (void)unSubscribeToOutboundNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions;

/*!
 Method to alert DNLocalEvent objects that a new event has been triggered.
 
 @param type the type of event that has been triggered.
 @param data the data to be passed to the listening class.
 
 @since 2.0.0.0
 */
- (void)publishOutboundNotification:(NSString *)type data:(id)data;

/*!
 Method used to register a services for use by other modules. NOTE: only one instance of a class can register for a
 specific service at a time. If another class registers for that service, the previous instance is overwritten.
 
 @param type     the type of service being offered.
 @param instance the instance of the class offering the service.
 
 @since 2.0.0.0
 */
- (void)registerService:(NSString *)type instance:(id)instance;

/*!
 Method to un-register an instance from a service. NOTE: It is crucial to un register instances from services when that
 object is about to be released from memory. Failure to do so may result in a dangling pointer or runtime exception if
 another module attempts to invoke the service.
 
 @param type the type of service that is being unregistered.
 
 @since 2.0.0.0
 */
- (void)unRegisterService:(NSString *)type;

/*!
 Method used to retrieve an object instance that has registered itself for the supplied service type.
 
 @param type the type of service that calling class needs.
 
 @return the instance of the class that has registered for that service.
 
 @since 2.0.0.0
 */
-(id)serviceForType:(NSString *)type;

/*!
 Method to register a module inside Donky Core, this will also submit the module name/version to the Donky Network.
 
 @param module the module that should be registered.
 
 @see DNModuleDefinition
 
 @since 2.0.0.0
 */
- (void)registerModule:(DNModuleDefinition *)moduleDefinition;

/*!
 Method to check if a particular module exists within the SDK.
 
 @param moduleName    the name of the module.
 @param moduleVersion the module version.
 
 @return BOOL indicating whether the supplied module name/version exists. If a module with the provided name exists
 but has a different version number, this will return false but an error will be output to the console/debug log.
 
 @since 2.0.0.0
 */
- (BOOL)isModuleRegistered:(NSString *)moduleName moduleVersion:(NSString *)moduleVersion;

/*!
 Method to retrieve an array containing all the DNModuleDefinitions currently registered against the SDK.
 
 @return array containing all DNModuleDefinitions currently registered.
 
 @since 2.0.0.0
 */
- (NSArray *)allRegisteredModules;

#pragma mark -
#pragma mark - Private... Not for public consumption. Public use is unsupported and may result in undesired SDK behaviour.

/*!
 PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 
 @warning Private, please do not use
 */
- (void)subscribeToDonkyNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions;

/*!
 PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour

 @warning Private, please do not use
 */
- (void)unSubscribeToDonkyNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions;

/*!
 PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 
 @warning Private, please do not use
 */
- (void)notificationsReceived:(NSDictionary *)dictionary;

@end
