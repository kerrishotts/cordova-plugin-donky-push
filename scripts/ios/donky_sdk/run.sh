#!/bin/bash

cd cocoapod-to-cordova
cp ../Podfile.Donky-Core-SDK ./Podfile
make build

# Not working and maybe not necessary
#read -p "Press ENTER to continue with data model copy"
#cp -R Pods/Donky-Core-SDK/src/modules/Core/Data\ Controller/Resources/DNDonkyDataModel.xcdatamodeld/ ../../../../src/ios/Donky-Core-SDK/resources/DNDonkyDataModel.xcdatamodeld/

read -p "Press ENTER to continue with Donky-CommonMessaging-Logic"
cp ../Podfile.Donky-CommonMessaging-Logic ./Podfile
make build

read -p "Press ENTER to continue with Donky-CommonMessaging-UI"
cp ../Podfile.Donky-CommonMessaging-UI ./Podfile
make build

read -p "Press ENTER to continue with Donky-SimplePush-Logic"
cp ../Podfile.Donky-SimplePush-Logic ./Podfile
make build

read -p "Press ENTER to continue with Donky-SimplePush-UI"
cp ../Podfile.Donky-SimplePush-UI ./Podfile
make build

read -p "Press ENTER to continue with AFNetworking"
cp ../Podfile.AFNetworking ./Podfile
make build

read -p "Press ENTER to continue with UIView-Autolayout"
cp ../Podfile.UIView-Autolayout ./Podfile
make build

read -p "Press ENTER to continue with clean up"
make clean