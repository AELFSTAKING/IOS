//
//  OConfig.h
//  AELFExchange
//
//  Created by tng on 2019/5/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OConfig : NSObject

+ (void)tingyunStartOptionSetup;

+ (NSString *)getIPAddressByHostName:(NSString *)strHostName;

+ (void)clearAllUIWebViewDataForDomain:(NSString *)domain;

@end

NS_ASSUME_NONNULL_END
