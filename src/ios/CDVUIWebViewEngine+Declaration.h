//
//  CDVUIWebViewEngine+Declaration.h
//  Headers to support backwards compatibility with Cordova iOS 3.
//  Created by Ben Moore on 16/03/2016.
//
//

#import <UIKit/UIKit.h>

#import <Cordova/CDVViewController.h>

@interface CDVUIWebViewEngine : NSObject

@property (nonatomic, strong) IBOutlet UIView* engineWebView;

@end