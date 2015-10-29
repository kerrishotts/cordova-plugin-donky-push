Donky Simple Push Notifications Plugin for Cordova/Phonegap
===========================================================

This Cordova/Phonegap plugin allows Cordova apps to easily receive Push Notifications via the [Donky network](http://www.mobiledonky.com).

- For Android, both GCM (Google Cloud Messaging) and non-GCM Android Open Source Push Notifications are supported.
- For iOS, APNS (Apple Push Notification Services) - also known as "Remote Notifications" - are used to deliver Push Notifications.
- Notifications will be received whether your app is currently running or not.
- Both simple and interactive Push Notifications are supported.


## Contents

* [Installing](#installing)
* [Using the plugin](#using-the-plugin)
* [Example project](#example-project)
* [License](#license)
 
# Installing

The plugin is registered on [npm](https://www.npmjs.com/package/cordova-plugin-donky-simple-push) as `cordova-plugin-donky-simple-push`

## Using the Cordova/Phonegap [CLI](http://docs.phonegap.com/en/edge/guide_cli_index.md.html)

    $ cordova plugin add cordova-plugin-donky-simple-push
    $ phonegap plugin add cordova-plugin-donky-simple-push

## Using [Cordova Plugman](https://github.com/apache/cordova-plugman)

    $ plugman install --plugin=cordova-plugin-donky-simple-push --platform=<platform> --project=<project_path> --plugins_dir=plugins

For example, to install for the Android platform

    $ plugman install --plugin=cordova-plugin-donky-simple-push --platform=android --project=platforms/android --plugins_dir=plugins

## PhoneGap Build

Add the following xml to your config.xml to use the latest version of this plugin from [npm](https://www.npmjs.com/package/cordova-plugin-donky-simple-push):

    <gap:plugin name="cordova-plugin-donky-simple-push" source="npm" />

# Using the plugin

The plugin uses the native Donky iOS and Android SDKs: for detailed information check out the [Donky documentation](http://docs.mobiledonky.com/docs/).

## Initial setup

In order to make use of this plugin in your app, you need to do the following:

### Register to use the Donky Network

If you haven't registered to use Donky, see the [getting started guide](http://docs.mobiledonky.com/docs/start-here) for how to get an API key.

### Put your API key into config.xml

TODO

### Setup APNS for iOS

In order for your app to use Push Notifications on iOS, you need to setup the required certificates. See [this guide](http://docs.mobiledonky.com/docs/remote-notification-certificates) for instructions how to do this.

Additionally, you will need to enable Push Notifications and Remote Notifications Background Mode in your iOS project. To do this:

- Open the `/platforms/ios/{project}.xcodeproj` file in XCode
- Go to the "Capabilities" pane
- Switch on "Push Notifications"
- Switch on "Background Modes" and check the "Remote notifications" box

## Plugin API

TODO


# Example project

An example project illustrating use of this plugin can be found here: [https://github.com/Donky-Network/cordova-plugin-donky-simple-push-example](https://github.com/Donky-Network/cordova-plugin-donky-simple-push-example)

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