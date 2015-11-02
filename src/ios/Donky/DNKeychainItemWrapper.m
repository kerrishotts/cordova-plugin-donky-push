//
//  DNKeychainItemWrapper.m
//  NAAS Core SDK Container
//
//  Created by Chris Wunsch on 19/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNKeychainItemWrapper.h"
#import "DNLoggingController.h"


@implementation DNKeychainItemWrapper


+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [@{(__bridge id) kSecClass : (__bridge id) kSecClassGenericPassword,
            (__bridge id) kSecAttrService : service,
            (__bridge id) kSecAttrAccount : service,
            (__bridge id) kSecAttrAccessible : (__bridge id) kSecAttrAccessibleAfterFirstUnlock} mutableCopy];
}

+ (void)setObject:(id)object forKey:(NSString *)key {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    keychainQuery[(__bridge id) kSecValueData] = [NSKeyedArchiver archivedDataWithRootObject:object];
    SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
}

+ (id)objectForKey:(NSString *)key {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
    keychainQuery[(__bridge id) kSecReturnData] = (id) kCFBooleanTrue;
    keychainQuery[(__bridge id) kSecMatchLimit] = (__bridge id) kSecMatchLimitOne;
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        }
        @catch (NSException *e) {
            DNErrorLog(@"Unarchive of %@ failed: %@", key, e);
            [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
        }
        @finally {}
    }
    if (keyData) CFRelease(keyData);
    return ret;
}

@end
