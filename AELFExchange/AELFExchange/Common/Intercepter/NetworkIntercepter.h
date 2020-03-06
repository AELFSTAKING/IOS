//
//  NetworkIntercepter.h
//  AELFExchange
//
//  Created by tng on 2019/5/23.
//  Copyright © 2019 aelf.io. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkIntercepter : NSURLProtocol {
    NSURLConnection *_connection;
    NSMutableData *_proRespData;
}

@end

NS_ASSUME_NONNULL_END
