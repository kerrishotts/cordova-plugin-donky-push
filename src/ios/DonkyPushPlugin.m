#import "DonkyPushPlugin.h"

BOOL debugEnabled = TRUE;
#define DLog(fmt, ...) { \
if (debugEnabled) \
NSLog((@"DonkyPushPlugin: " fmt), ##__VA_ARGS__); \
}

@implementation DonkyPushPlugin

@synthesize cordova_command;

/*
 * API
 */
@end