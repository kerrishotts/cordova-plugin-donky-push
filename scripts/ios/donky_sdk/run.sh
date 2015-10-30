#!/bin/bash
cd cocoapod-to-cordova
cp ../Podfile.Donky-Core-SDK ./Podfile
make build
cp -R Pods/Donky-Core-SDK/src/modules/Core/Data\ Controller/Resources/DNDonkyDataModel.xcdatamodeld/ ../../../../src/ios/Donky-Core-SDK/resources/DNDonkyDataModel.xcdatamodeld/
cp ../Podfile.Donky-CommonMessaging-Logic./Podfile
make build
cp ../Podfile.Donky-CommonMessaging-UI ./Podfile
make build
cp ../Podfile.Donky-SimplePush-Logic ./Podfile
make build
cp ../Podfile.Donky-SimplePush-UI ./Podfile
make build
cp ../Podfile.AFNetworking ./Podfile
make build
cp ../Podfile.UIView-Autolayout ./Podfile
make build
make clean