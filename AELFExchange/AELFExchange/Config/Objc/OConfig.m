//
//  OConfig.m
//  AELFExchange
//
//  Created by tng on 2019/5/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

#import "OConfig.h"
#import <tingyunApp/NBSAppAgent.h>
#include <netdb.h>
#include <sys/socket.h>
#include <arpa/inet.h>

@implementation OConfig

+ (void)tingyunStartOptionSetup {
    [NBSAppAgent setStartOption:NBSOption_Net|NBSOption_UI|NBSOption_hybrid|NBSOption_Socket|NBSOption_StrideApp|NBSOption_ANR|NBSOption_Behaviour|NBSOption_CDNHeader];
}

+ (NSString *)getIPAddressByHostName:(NSString *)strHostName {
    const char* szname = [strHostName UTF8String];
    struct hostent* phot ;
    @try {
        phot = gethostbyname(szname);
    } @catch (NSException * e) {
        return nil;
    }
    
    struct in_addr ip_addr;
    //h_addr_list[0]里4个字节,每个字节8位，此处为一个数组，一个域名对应多个ip地址或者本地时一个机器有多个网卡
    if (NULL == phot) return nil;
    if (sizeof(phot->h_addr_list) == 0) return nil;
    memcpy(&ip_addr,phot->h_addr_list[0],4);
    
    char ip[20] = {0};
    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
    
    NSString* strIPAddress = [NSString stringWithUTF8String:ip];
    return strIPAddress;
}

+ (void)clearAllUIWebViewDataForDomain:(NSString *)domain {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [OConfig removeApplicationLibraryDirectoryWithDirectory:@"Caches"];
    [OConfig removeApplicationLibraryDirectoryWithDirectory:@"WebKit"];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if (domain.length > 0) {
            if ([cookie.domain containsString:domain]) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
        } else {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
    [OConfig removeApplicationLibraryDirectoryWithDirectory:@"Cookies"];
}

+ (void)removeApplicationLibraryDirectoryWithDirectory:(NSString *)dirName {
    NSString *dir = [[[[NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES) lastObject]stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:dirName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dir]) {
        [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
    }
}

@end
