//
//  Crypt.h
//  Regroupd
//
//  Created by Gal Blank on 4/9/15.
//  Copyright (c) 2015 Gal Blank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>

#define KEY_256_RGRPD @"0234567890123456"
#define SALT_RGRPD    @"6543210987654321"
#define IV64_RGRPD    @"9b4YUjBzm05ZquPc9ER+tA=="

@interface GCrypto : NSObject

-(NSString*) generateKey;

-(NSString*) encryptMap:(NSMutableDictionary*)plainMap withKey:(NSString*)key;

-(NSString*) encrypt:(NSString*)plainText key:(NSString*)key;
-(NSString*) decrypt:(NSString*)cipherText key:(NSString*)key;
- (NSString*) decryptData:(NSData*)ciphertext withKey:(NSString*)key;
- (NSData*) encryptString:(NSString*)plaintext withKey:(NSString*)key;
- (NSData *)AES256DecryptString:(NSString*)text WithKey:(NSString *)key;
- (NSData *)AES256EncryptString:(NSString*)text WithKey:(NSString *)key;
+(NSString*) encryptString:(NSString*)plaintext withKey:(NSString*)key;
+(NSString*) decryptString:(NSString*)ciphertext withKey:(NSString*)key;

@end
