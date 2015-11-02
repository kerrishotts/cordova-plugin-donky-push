# Updating the Donky SDK modules

The versions of the native Donky SDK modules used by this plugin are explicitly defined, and so to update the versions of the modules being used, use the following procedures:

## Android

The Android SDK modules are dynamically downloaded installed into the Cordova project during the Gradle build process.
The module versions are defined in the [plugin.xml](plugin.xml) by `<framework>` tags, for example:

    <framework src="net.donky:donky-core:2.2.0.2" />

To change the SDK module versions that are used, change the version number in these tags, for example:

    <framework src="net.donky:donky-core:2.2.1.0" />

## iOS

While the iOS SDK modules are available via [Cocoapods](https://cocoapods.org/?q=Donky), in order to make use of them in this Cordova plugin, the compiled module components are explicitly included in this repo within subfolders of [src/ios](src/ios) and are explicitly referenced in the [plugin.xml](../plugin.xml).

The compiled components and references are generated via scripts located in [scripts/ios/donky_sdk](../scripts/ios/donky_sdk). For instructions how to update the iOS SDK modules, see the [README.md](../scripts/ios/donky_sdk/README.md) in that folder.