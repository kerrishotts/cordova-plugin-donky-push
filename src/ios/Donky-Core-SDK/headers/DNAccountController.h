//
//  DNAccountController.h
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNBlockDefinitions.h"
#import "DNDeviceDetails.h"
#import "DNRegistrationDetails.h"
#import "DNClientDetails.h"
#import "DNModuleDefinition.h"
#import "DNUserDetails.h"

/*!
 DNAccountController is responsible for all actions around device and user registration. Use this class to register a new device on the Network. Updating
 user details on the network. Determining the state of the user, if they are logged in, registered or suspended. This class also allows you to suspend and un suspend users.
 
  @since 2.0.0.0
 */
@interface DNAccountController : NSObject

/*!
 Method to update multiple parts of the users and device details at once.
 
 @param userDetails   the user details to update on the network. Can be nil to create a new anonymous registration.
 @param deviceDetails the device detailst to update on the network. Can be nil.
 @param successBlock  block called upon successful completion of the network operation.
 @param failureBlock  block called upon failure of the network operation.
 
 @see DNUserDetails
 @see DNDeviceDetails
 
 @since 2.0.0.0
 */
+ (void)updateRegistrationDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 Method to update the user that is linked against this account on the network.
 
 @param userDetails  the user details that should be updated on the network.
 @param successBlock      block called upon successful completion.
 @param failureBlock      block called upon failure to complete the operation.
 
 @see DNUserDetails
 
 @since 2.0.0.0
 */
+ (void)updateUserDetails:(DNUserDetails *)userDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock) failureBlock;

/*!
 Method to update the device details linked against this device on the network. DNDeviceDetails.
 
 @param deviceDetails the device details with the properties to use when updating the network details. Pass nil to create a 'fresh' device.
 @param successBlock  block called upon successful completion.
 @param failureBlock  block called upon failure to complete the operation.
 
 @see DNDeviceDetails
 
  @since 2.0.0.0
 */
+ (void)updateDeviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 Method to 'Re-Register' this device on the network. @warning *Warning* using this method will completely delete all local content for the existing user. The device will be reassigned on the network which could potentially delete the user account on the Donky Network. Use with caution.
 
 @param userDetails     the details of the user to use for the re-registration. Pass nil to create a new anonymous user.
 @param deviceDetails the details of the device to use in the re-registration.
 @param successBlock  block called upon successful completion of the operation.
 @param failureBlock  block called upon failure to complete the operation.
 
 @see DNUserDetails
 @see DNDeviceDetails
 
 
 @since 2.0.0.0
 */
+ (void)replaceRegistrationDetailsWithUserDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 Method to retrieve the current device registration details containing all three of the registration detail objects.
 
 @return a new DNRegistration object containing all the details needed to register a device.
 
 @see DNRegistrationDetails 
 @see DNUserDetails
 @see DNDeviceDetails
 
 @since 2.0.0.0
 */
+ (DNRegistrationDetails *)registrationDetails;

/*!
  Method to return the current device user object with the specified parameters. *Warning* ensure that updateDeviceUser:success:failure is called with this to also update the details stored on the Donky Network.
 
 @param userID               the userID to give the device user.
 @param displayName          the display name to give the device user.
 @param email                the email address to give the device user.
 @param countryCode          the country code to give the device user NOTE: this is only required if also supplying a mobile number.
 @param mobileNumber         the mobile number to give the device user.
 @param additionalProperties any additionalProperties to give the device user. NOTE: limit to 50 separate records.
 
 @see DNUserDetails
 
 @return the current DNUserDetails object with the new specified details.
 
 @since 2.0.0.0
 */
+ (DNUserDetails *)userID:(NSString *)userID displayName:(NSString *)displayName emailAddress:(NSString *)email mobileNumber:(NSString *)mobileNumber countryCode:(NSString *)countryCode firstName:(NSString *)firstName lastName:(NSString *)lastName avatarID:(NSString *)avatarID selectedTags:(NSMutableArray *)selectedTags additionalProperties:(NSDictionary *)additionalProperties;

/*!
 This saves the provided tags on the network.
 
 @param tags         the tags that should be saved against this user on the network.
 @param successBlock  block called upon successful completion of the operation.
 @param failureBlock  block called upon failure to complete the operation.
 
 @see DNUserDetails
 
 @since 2.0.0.0
 */
+ (void)saveUserTags:(NSMutableArray *)tags success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 Method to retrieve all of the tags on this app space. The current users selected tags will be have a 
 true 'isSelected' value. An array of Key vlaue pairs will be sent in the successBlock responseData object.
 
 @param successBlock  block called upon successful completion of the operation.
 @param failureBlock  block called upon failure to complete the operation.
 
 @since 2.0.0.0
 */
+ (void)usersTags:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 Method to update a users additioanl properties. NOTE: This is desctructive, if you don't pass in all existing properties as well as 
 additional ones and changes, you will lose them.
 
 @param newAdditionalProperties the new complete additional properties to be saved against this user.
 @param successBlock  block called upon successful completion of the operation.
 @param failureBlock  block called upon failure to complete the operation.
 
 @since 2.2.2.7
 */
+ (void)updateAdditionalProperties:(NSDictionary *)newAdditionalProperties success:(DNNetworkSuccessBlock) successBlock failure:(DNNetworkFailureBlock) failureBlock;

/*!
 Method to determine if the current device holds a valid registration.
 
 @return BOOL indicating if the device has an authorised user.
 
 @since 2.0.0.0
 */
+ (BOOL)isRegistered;

#pragma mark - 

#pragma mark - Private... Not for public consumption. Public use of these API's is unsupported. 

/*!
  PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 */
+ (void)initialiseUserDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
  PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 */
+ (void)refreshAccessTokenSuccess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 */
+ (void)updateClientModules:(NSArray *)modules;

/*!
 PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 */
+ (void)updateNetworkDetails;

@end
