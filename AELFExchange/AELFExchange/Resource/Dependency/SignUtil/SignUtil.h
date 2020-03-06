//
//  SignUtil.h
//  AELFExchange
//
//  Created by tng on 2019/3/4.
//  Copyright © 2019 aelf.io. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SignUtil : NSObject

#pragma mark - RSA Begin.
+ (NSString *)rsa_encryptString:(NSString *)str publicKeyWithContentsOfFile:(NSString *)path;
/* START: Encryption with RSA public key */
+ (NSString *)rsa_encryptString:(NSString *)str publicKey:(NSString *)pubKey;
/* END: Encryption with RSA public key */

/* START: Decryption with RSA private key */
+ (NSString *)rsa_decryptString:(NSString *)str privateKey:(NSString *)privKey;
+ (NSData *)decryptData:(NSData *)data privateKey:(NSString *)privKey;

/**
 SHA256 with RSA encode.
 
 @param plainData data.
 @param privateKey the private key string.
 @return data.
 */
+ (NSData *)rsaSHA256SignData:(NSData *)plainData privateKey:(NSString *)privateKey;

/**
 SHA256 with RSA decode;
 
 @param plainData data.
 @param signature signed data.
 @param publicKey the public key string.
 @return succeed.
 */
+ (BOOL)rsaSHA256VerifyData:(NSData *)plainData withSignature:(NSData *)signature publicKey:(NSString *)publicKey;
#pragma mark - RSA End.

@end

NS_ASSUME_NONNULL_END
