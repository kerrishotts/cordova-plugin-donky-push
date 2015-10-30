Donky Simple Push Notifications Plugin for Cordova/Phonegap
===========================================================

This Cordova/Phonegap plugin allows Cordova apps to easily receive Push Notifications and to send/receive cross-platform peer-to-peer notifications via the [Donky network](http://www.mobiledonky.com).

Currently supported platforms are: Android and iOS

**Push Notifications**

- For Android, both GCM (Google Cloud Messaging) and non-GCM Android Open Source Push Notifications are supported.
- For iOS, APNS (Apple Push Notification Services) - also known as "Remote Notifications" - are used to deliver Push Notifications.
- Notifications will be received whether your app is currently running or not.
- Both simple and interactive Push Notifications are supported.

**Peer-to-peer Notifications**

- Communicate peer-to-peer with other users on multiple platforms.
- Example usages might be simple chat/messaging or a chess game where moves are sent across the Donky Network.

## Contents

* [Installing](#installing)
* [Using the plugin](#using-the-plugin)
* [Example project](#example-project)
* [Updating the Donky SDK modules](#updating-the-donky-sdk-modules)
* [License](#license)
 
# Installing

The plugin can be installed directly from its GitHub repo [https://github.com/Donky-Network/cordova-plugin-donky-simple-push](https://github.com/Donky-Network/cordova-plugin-donky-simple-push):

## Using the Cordova/Phonegap [CLI](http://docs.phonegap.com/en/edge/guide_cli_index.md.html)

    $ cordova plugin add https://github.com/Donky-Network/cordova-plugin-donky-simple-push
    $ phonegap plugin add https://github.com/Donky-Network/cordova-plugin-donky-simple-push

## Using [Cordova Plugman](https://github.com/apache/cordova-plugman)

    $ plugman install --plugin=https://github.com/Donky-Network/cordova-plugin-donky-simple-push --platform=<platform> --project=<project_path> --plugins_dir=plugins

For example, to install for the Android platform

    $ plugman install --plugin=https://github.com/Donky-Network/cordova-plugin-donky-simple-push --platform=android --project=platforms/android --plugins_dir=plugins

## Uninstalling

The plugin ID is `cordova-plugin-donky-simple-push`, so to uninstall it:

    $ cordova plugin rm cordova-plugin-donky-simple-push

# Using the plugin

The plugin uses the native Donky iOS and Android SDKs: for detailed information check out the [Donky documentation](http://docs.mobiledonky.com/docs/).

## Initial setup

In order to make use of this plugin in your app, you need to do the following:

### Register to use the Donky Network

If you haven't registered to use Donky, see the [getting started guide](http://docs.mobiledonky.com/docs/start-here) for how to get an API key.

### Put your API key into config.xml

Your Donky API key must be added as a preference to your Cordova config.xml. The plugin will pick it up from here and use it when connecting to the Donky Network. It should be added in the following format inside the `<widget>` element:

    <preference name="DONKY_API_KEY" value="{YOUR_API_KEY}" />
    
For example:
    
    <preference name="DONKY_API_KEY" value="QqKcc3JGT8ZLtZtWNG+4CSxt+QCBw4vLdUl7NzKWo4oRfRUWUXca2uPnNVfg+uFoyVORPWcgK3CHUBvXCcvELg" />

### Setup APNS for iOS

In order for your app to use Push Notifications on iOS, you need to setup the required certificates. See [this guide](http://docs.mobiledonky.com/docs/remote-notification-certificates) for instructions how to do this.

Additionally, you will need to enable Push Notifications and Remote Notifications Background Mode in your iOS project. To do this:

- Open the `/platforms/ios/{project}.xcodeproj` file in XCode
- Go to the "Capabilities" pane
- Switch on "Push Notifications"
- Switch on "Background Modes" and check the "Remote notifications" box

### Wait for Donky initialisation
The Donky SDK begins initialisation when your app first starts up. This happens in parallel with the initialisation of the Cordova Webview and is asynchronous because completion of the SDK initialisation depends on the results of remote network requests.

Therefore, before your app starts performing its operations, you must first wait for both the Cordova Webview to be ready (signalled by the `"deviceready"` event) **and** for the Donky SDK to be ready (signalled by the `"donkyready"` event).

The plugin provides a combined event `"deviceanddonkyready"`, which you can listen for in the same way as `"deviceready"`. When this event is fired, it means both Cordova and the Donky SDK are ready and your app can now start performing operations:

    document.addEventListener("deviceanddonkyready", initMyApp, false);
    function initMyApp(){
        console.log("Both Cordova and Donky SDK are ready. My app can now start to do stuff.");
    }

## Example usage

Once the plugin is installed and setup with your API Key, there's nothing more you need to do to receive Push Notifications.

Before you can start sending/receiving custom peer-to-peer notifications between users, details of the user and device must be registered with the Donky Network. You can do this using the `updateRegistrationDetails()` function:

    cordova.plugins.donky.updateRegistrationDetails(success, error, userDetails, deviceDetails);

You can subscribe to receive notifications of a given type:

    cordova.plugins.donky.subscribeToContentNotifications(success, error, "myMessageType", onReceiveMyMessage);

You can send a notification of a specified type to a particular user which contains custom data:

    cordova.plugins.donky.sendContentNotificationToUser(
        function(){
            console.log("Successfully sent");
        },function(error){
            console.error("Error sending: "+error);
        },
        "fred.bloggs",
        "myMessageType",
        {
            some: "data"
        }
    );

Notifications can be queued for batch sending:

    cordova.plugins.donky.sendContentNotificationToUser(
        function(){
            console.log("Successfully sent");
        },function(error){
            console.error("Error sending: "+error);
        },
        "fred.bloggs",
        "myMessageType",
        {
            some: "data"
        },
        true // queue notification for sending
    );

Calling `synchronise()` will send any locally queued notifications and check for/receive pending remote notifications:

    cordova.plugins.donky.synchronise(
        function(){
            console.log("Successfully synchronised");
        },function(error){
            console.error("Error synchronising: "+error);
        }
    );



## Plugin API

The plugin is exposed in Cordova as `cordova.plugins.donky` on the `window` object.

### updateUserDetails()

Updates registered user details.

    cordova.plugins.donky.updateUserDetails(success, error, userDetails);

Parameters:

- `{function} success` - callback to be invoked on successful update.
- `{function} error` - callback to be invoked on error updating. A single `{string}` argument will be passed to this containing an error message.
- `{object} userDetails` - object specifying [user details](http://docs.mobiledonky.com/docs/sdk-common-types#userdetails). May contain the following keys:
    - `{string} userId` - The id for the App User account on the Donky Network
    - `{string} displayName` - Display name for the user
    - `{string} firstName` - First name for the user
    - `{string} lastName` - Last name for the user
    - `{string} emailAddress` - E-mail address for the user
    - `{string} mobileNumber` - Mobile number for the user
    - `{string} countryCode` - 3-digit ISO country code for the user
    - `{string} avatarId` - ID of an avatar for the user
    - `{object} additionalProperties` - key/value map of custom user properties
    - `{array} selectedTags` - list of selected tags

Example usage:

    cordova.plugins.donky.updateUserDetails(
        function(){
            console.log("Successfully updated");
        },function(error){
            console.error("Error updating: "+error);
        },
        {
            userId:"fred.bloggs",
            displayName:"Fred_Bloggs",
            firstName:"Fred",
            lastName:"Bloggs",
            emailAddress:"fred@bloggs.com",
            mobileNumber:"07890 123456",
            countryCode:"GBR",
            avatarId:"671E8B4C-8536-4BC9-AFB4-F43C940DB4DE|20110609|UKDEV1",
            additionalProperties:{
                foo: "bar"
            },
            selectedTags: [
                "tag1",
                "tag2"
            ]
        }
    );

### updateDeviceDetails()

Updates registered device details.

    cordova.plugins.donky.updateDeviceDetails(success, error, deviceDetails);

Parameters:

- `{function} success` - callback to be invoked on successful update.
- `{function} error` - callback to be invoked on error updating. A single `{string}` argument will be passed to this containing an error message.
- `{object} deviceDetails` - object specifying [device details](http://docs.mobiledonky.com/docs/sdk-common-types#devicedetails). May contain the following keys:
    - `{string} deviceType` - Make/model of the device
    - `{string} deviceName` - User-defined name of the device
    - `{object} additionalProperties` - key/value map of custom device properties

Example usage:

    cordova.plugins.donky.updateDeviceDetails(
        function(){
            console.log("Successfully updated");
        },function(error){
            console.error("Error updating: "+error);
        },
        {
            deviceName: "Fred's iPhone",
            deviceType: "iPhone 6s",
            additionalProperties:{
                osVersion: "iOS 9.0.2"
            }
        }
    );

### updateRegistrationDetails()

Updates registered user and device details

    cordova.plugins.donky.updateRegistrationDetails(success, error, userDetails, deviceDetails);

Parameters:

- `{function} success` - callback to be invoked on successful update.
- `{function} error` - callback to be invoked on error updating. A single `{string}` argument will be passed to this containing an error message.
- `{object} userDetails` - object specifying [user details](http://docs.mobiledonky.com/docs/sdk-common-types#userdetails). May contain the following keys:
    - `{string} userId` - The id for the App User account on the Donky Network
    - `{string} displayName` - Display name for the user
    - `{string} firstName` - First name for the user
    - `{string} lastName` - Last name for the user
    - `{string} emailAddress` - E-mail address for the user
    - `{string} mobileNumber` - Mobile number for the user
    - `{string} countryCode` - 3-digit ISO country code for the user
    - `{string} avatarId` - ID of an avatar for the user
    - `{object} additionalProperties` - key/value map of custom user properties
    - `{array} selectedTags` - list of selected tags
- `{object} deviceDetails` - object specifying [device details](http://docs.mobiledonky.com/docs/sdk-common-types#devicedetails). May contain the following keys:
    - `{string} deviceType` - Make/model of the device
    - `{string} deviceName` - User-defined name of the device
    - `{object} additionalProperties` - key/value map of custom device properties

Example usage:

    cordova.plugins.donky.updateRegistrationDetails(
        function(){
            console.log("Successfully updated");
        },function(error){
            console.error("Error updating: "+error);
        },
        {
            userId:"fred.bloggs",
            displayName:"Fred_Bloggs",
            firstName:"Fred",
            lastName:"Bloggs",
            emailAddress:"fred@bloggs.com",
            mobileNumber:"07890 123456",
            countryCode:"GBR",
            avatarId:"671E8B4C-8536-4BC9-AFB4-F43C940DB4DE|20110609|UKDEV1",
            additionalProperties:{
                foo: "bar"
            },
            selectedTags: [
                "tag1",
                "tag2"
            ]
        },
        {
            deviceName: "Fred's iPhone",
            deviceType: "iPhone 6s",
            additionalProperties:{
                osVersion: "iOS 9.0.2"
            }
        }
    );

### replaceRegistrationDetails()

Replaces registered user and device details

    cordova.plugins.donky.replaceRegistrationDetails(success, error, userDetails, deviceDetails);

Parameters:

- `{function} success` - callback to be invoked on successful update.
- `{function} error` - callback to be invoked on error updating. A single `{string}` argument will be passed to this containing an error message.
- `{object} userDetails` - object specifying [user details](http://docs.mobiledonky.com/docs/sdk-common-types#userdetails). May contain the following keys:
    - `{string} userId` - The id for the App User account on the Donky Network
    - `{string} displayName` - Display name for the user
    - `{string} firstName` - First name for the user
    - `{string} lastName` - Last name for the user
    - `{string} emailAddress` - E-mail address for the user
    - `{string} mobileNumber` - Mobile number for the user
    - `{string} countryCode` - 3-digit ISO country code for the user
    - `{string} avatarId` - ID of an avatar for the user
    - `{object} additionalProperties` - key/value map of custom user properties
    - `{array} selectedTags` - list of selected tags
- `{object} deviceDetails` - object specifying [device details](http://docs.mobiledonky.com/docs/sdk-common-types#devicedetails). May contain the following keys:
    - `{string} deviceType` - Make/model of the device
    - `{string} deviceName` - User-defined name of the device
    - `{object} additionalProperties` - key/value map of custom device properties

Example usage:

    cordova.plugins.donky.replaceRegistrationDetails(
        function(){
            console.log("Successfully replaced");
        },function(error){
            console.error("Error replacing: "+error);
        },
        {
            userId:"fred.bloggs",
            displayName:"Fred_Bloggs",
            firstName:"Fred",
            lastName:"Bloggs",
            emailAddress:"fred@bloggs.com",
            mobileNumber:"07890 123456",
            countryCode:"GBR",
            avatarId:"671E8B4C-8536-4BC9-AFB4-F43C940DB4DE|20110609|UKDEV1",
            additionalProperties:{
                foo: "bar"
            },
            selectedTags: [
                "tag1",
                "tag2"
            ]
        },
        {
            deviceName: "Fred's iPhone",
            deviceType: "iPhone 6s",
            additionalProperties:{
                osVersion: "iOS 9.0.2"
            }
        }
    );

### sendContentNotificationToUser()

Queues or immediately sends a content notification to a single user

    cordova.plugins.donky.sendContentNotificationToUser(success, error, userId, notificationType, data, queue);

Parameters:

- `{function} success` - callback to be invoked on success.
- `{function} error` - callback to be invoked on error. A single `{string}` argument will be passed to this containing an error message.
- `{string} userId` - ID of user on the Donky Network to send the notification to
- `{string} notificationType` - Type of notification to send
- `{object} data` - key/value map of notification data
- `{boolean} queue` - if true, notification will be queued for sending. If false, notification will be sent immediately. Defaults to false.

Example usage:

    cordova.plugins.donky.sendContentNotificationToUser(
        function(){
            console.log("Successfully sent");
        },function(error){
            console.error("Error sending: "+error);
        },
        "fred.bloggs",
        "aMessageType",
        {
            some: "data"
        },
        false
    );

### sendContentNotificationToUsers()

Queues or immediately sends a content notification to multiple users

    cordova.plugins.donky.sendContentNotificationToUsers(success, error, users, notificationType, data, queue);

Parameters:

- `{function} success` - callback to be invoked on success.
- `{function} error` - callback to be invoked on error. A single `{string}` argument will be passed to this containing an error message.
- `{array} users` - list of user IDs on the Donky Network to send the notification to
- `{string} notificationType` - Type of notification to send
- `{object} data` - key/value map of notification data
- `{boolean} queue` - if true, notification will be queued for sending. If false, notification will be sent immediately. Defaults to false.

Example usage:

    cordova.plugins.donky.sendContentNotificationToUsers(
        function(){
            console.log("Successfully queued");
        },function(error){
            console.error("Error queuing: "+error);
        },
        ["fred.bloggs","joe.bloggs","jane.bloggs"],
        "aMessageType",
        {
            some: "data"
        },
        true
    );

### synchronise()

Synchronises locally and remotely queued notifications with the Donky network

    cordova.plugins.donky.synchronise(success, error);

Parameters:

- `{function} success` - callback to be invoked on success.
- `{function} error` - callback to be invoked on error. A single `{string}` argument will be passed to this containing an error message.

Example usage:

    cordova.plugins.donky.synchronise(
        function(){
            console.log("Successfully synchronised");
        },function(error){
            console.error("Error synchronising: "+error);
        }
    );

### subscribeToContentNotifications()

Subscribes to receive notifications of a specified custom type.

    cordova.plugins.donky.subscribeToContentNotifications(success, error, notificationType, handlerFn);

Parameters:

- `{function} success` - callback to be invoked on successfully subscribing for notifications
- `{function} error` - callback to be invoked on an error subscribing to receive notifications.
- `{string} notificationType` - name of custom notification type to subscribe to. Must match the notification type used when sending custom notifications.
- `{function} handlerFn` - callback to be invoked on receiving notification of specified type. A single `{object}` argument will be passed to this which contains the notification content as a JSON object with the following keys:
    - `{string} customType` - the custom type of the notification (useful if using a single handler for multiple types) 
    - `{object} customData` - if the notification was successfully received, this will be present and contain the notification data payload as a JSON structure.
    - `{string} error` - if an error occurred receiving the notification, this will be present and contain the error message.

Example usage:

    cordova.plugins.donky.subscribeToContentNotifications(
        function(){
            console.log("Successfully subscribed for notifications);
        },function(error){
            console.error("Error subscribing for notifications: "+error);
        },
        "myCustomType",
        function(data){
            if(data.error){
                console.error("Error receiving notification of type '"+data.customType+"': "+data.error);
            }else{
                console.log("Successfully received notification of type '"+data.customType+"' with data: "+JSON.stringify(data.customData));
            }
        }
    );


# Example project

An example project illustrating use of this plugin can be found here: [https://github.com/Donky-Network/cordova-plugin-donky-simple-push-example](https://github.com/Donky-Network/cordova-plugin-donky-simple-push-example)

# Updating the Donky SDK modules

The versions of the native Donky SDK modules used by this plugin are explicitly defined, and so to update the versions of the modules being used, use the following procedures:

## Android

The Android SDK modules are dynamically downloaded installed into the Cordova project during the Gradle build process.
The module versions are defined in the [plugin.xml](plugin.xml) by `<framework>` tags, for example:

    <framework src="net.donky:donky-core:2.2.0.2" />

To change the SDK module versions that are used, change the version number in these tags, for example:

    <framework src="net.donky:donky-core:2.2.1.0" />

## iOS

While the iOS SDK modules are available via [Cocoapods](https://cocoapods.org/?q=Donky), in order to make use of them in this Cordova plugin, the compiled module components are explicitly included in this repo within subfolders of [src/ios](src/ios) and are explicitly referenced in the [plugin.xml](plugin.xml).

The compiled components and references are generated via scripts located in [scripts/ios/donky_sdk](scripts/ios/donky_sdk). For instructions how to update the iOS SDK modules, see the [README.md](scripts/ios/donky_sdk/README.md) in that folder.

# License

The MIT License

Copyright (c) 2015 Donky.
http://www.mobiledonky.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.