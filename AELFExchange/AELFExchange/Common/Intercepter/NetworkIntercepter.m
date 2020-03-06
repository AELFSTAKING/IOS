//
//  NetworkIntercepter.m
//  AELFExchange
//
//  Created by tng on 2019/5/23.
//  Copyright © 2019 aelf.io. All rights reserved.
//

#import "NetworkIntercepter.h"
#import "AELFExchange-Swift.h"

static NSString *cachingURLHeader = @"cex-Intercepter-has-processed";

@implementation NetworkIntercepter

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([request valueForHTTPHeaderField:cachingURLHeader] == nil) {
        return [request.URL.absoluteString containsString:@".js"];
    }
    return false;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    NSString *tims = [NSString stringWithFormat:@"%lld", (long long)([NSDate date].timeIntervalSince1970*1000)];
    NSString *origUrlStr = request.URL.absoluteString;
    NSString *symbol = [origUrlStr containsString:@"?"] ? @"&":@"?";
    NSString *urlStr = [NSString stringWithFormat:@"%@%@deviceId=%@&t=%@",origUrlStr,symbol,[Util deviceID],tims];
    mutableReqeust.URL = [NSURL URLWithString:urlStr];
    return mutableReqeust;
}

- (void)startLoading {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSMutableURLRequest *proxyRequest = [self.request mutableCopy];
    [proxyRequest setValue:@"" forHTTPHeaderField:cachingURLHeader];
    _connection = [[NSURLConnection alloc] initWithRequest:proxyRequest delegate:self startImmediately:false];
    [_connection start];
#pragma clang diagnostic pop
}

- (void)stopLoading {
    [_connection cancel];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if(response != nil) {
        NSMutableURLRequest *redirectableRequest = [request mutableCopy];
        [redirectableRequest setValue:nil forHTTPHeaderField:cachingURLHeader];
        [self.client URLProtocol:self wasRedirectedToRequest:redirectableRequest redirectResponse:response];
        return redirectableRequest;
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)sourceData {
    if (_proRespData == nil) {
        _proRespData = [sourceData mutableCopy];
    } else {
        [_proRespData appendData:sourceData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSData *getData = _proRespData ;
    [self.client URLProtocol:self didLoadData:getData];
    [self.client URLProtocolDidFinishLoading:self];
}

@end
