//
//  Crypt.m
//  Regroupd
//
//  Created by Gal Blank on 4/9/15.
//  Copyright (c) 2015 Gal Blank. All rights reserved.
//

#import "GCrypto.h"
#import "StringHelper.h"
#import "GTMBase64.h"
#import "Utils.h"

@implementation GCrypto

+ (NSData *)AES256EncryptString:(NSString*)text WithKey:(NSString *)_key {
    
    // TODO: _key curently disabled -- should be fixed in final code
    
    // TODO: preamble setup -- should be moved to the app initialisation
    NSMutableData* hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    NSMutableData* key = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(SALT_RGRPD.UTF8String, (CC_LONG)strlen(SALT_RGRPD.UTF8String), hash.mutableBytes);
    
    CCKeyDerivationPBKDF(kCCPBKDF2, KEY_256_RGRPD.UTF8String, strlen(KEY_256_RGRPD.UTF8String), hash.bytes, hash.length, kCCPRFHmacAlgSHA1, 1000, key.mutableBytes, key.length);
    
    NSData* iv = [[NSData alloc] initWithBase64EncodedString:IV64_RGRPD options:0];
    
    /*NSLog(@"Hash : %@",[hash base64EncodedStringWithOptions:0]);
    NSLog(@"Key : %@",[key base64EncodedStringWithOptions:0]);
    NSLog(@"IV : %@",[iv base64EncodedStringWithOptions:0]);*/
    // end preamble
    
    NSData* textData = [text dataUsingEncoding:NSUTF8StringEncoding];
    
    size_t bytesEncrypted = 0;
    NSMutableData* encrypted = [NSMutableData dataWithLength:text.length + kCCBlockSizeAES128];
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          key.bytes,
                                          key.length,
                                          iv.bytes,
                                          textData.bytes, textData.length,
                                          encrypted.mutableBytes, encrypted.length, &bytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSMutableData dataWithBytes:encrypted.mutableBytes length:bytesEncrypted];
        // This needs to be base64 as string e.g.
        // NSString* encrypted64 = [[NSMutableData dataWithBytes:encrypted.mutableBytes length:bytesEncrypted] base64EncodedStringWithOptions:0];
    }
    
    return nil;
}

+ (NSData *)AES256DecryptString:(NSString*)text WithKey:(NSString *)_key {
    // TODO: _key curently disabled -- should be fixed in final code
    
    // TODO: preamble setup -- should be moved to the app initialisation
    NSMutableData* hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    NSMutableData* key = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(SALT_RGRPD.UTF8String, (CC_LONG)strlen(SALT_RGRPD.UTF8String), hash.mutableBytes);
    
    CCKeyDerivationPBKDF(kCCPBKDF2, KEY_256_RGRPD.UTF8String, strlen(KEY_256_RGRPD.UTF8String), hash.bytes, hash.length, kCCPRFHmacAlgSHA1, 1000, key.mutableBytes, key.length);
    
    NSData* iv = [[NSData alloc] initWithBase64EncodedString:IV64_RGRPD options:0];
    
    NSLog(@"Hash : %@",[hash base64EncodedStringWithOptions:0]);
    NSLog(@"Key : %@",[key base64EncodedStringWithOptions:0]);
    NSLog(@"IV : %@",[iv base64EncodedStringWithOptions:0]);
    // end preamble
    
    // the received value should be base64 encoded
    NSData* encryptedWithout64 = [[NSData alloc] initWithBase64EncodedString:text options:0];
    NSMutableData* decrypted = [NSMutableData dataWithLength:encryptedWithout64.length + kCCBlockSizeAES128];
    
    size_t bytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          key.bytes,
                                          key.length,
                                          iv.bytes,
                                          encryptedWithout64.bytes, encryptedWithout64.length,
                                          decrypted.mutableBytes, decrypted.length, &bytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSMutableData dataWithBytes:decrypted.mutableBytes length:bytesDecrypted];
        // This should be a string when used, like:
        // NSString* outputString = [[NSString alloc] initWithData:outputMessage encoding:NSUTF8StringEncoding];
    }
    return nil;
}


+ (NSString*) encryptString:(NSString*)plaintext withKey:(NSString*)key {
    return [[self AES256EncryptString:plaintext WithKey:KEY_256_RGRPD] base64EncodedStringWithOptions:0];
}

+ (NSString*) decryptString:(NSString*)ciphertext withKey:(NSString*)key {
    return [[NSString alloc] initWithData:[self AES256DecryptString:ciphertext WithKey:KEY_256_RGRPD]
                                 encoding:NSUTF8StringEncoding];
}


-(NSString*)generateKey
{
    NSString *key = nil;
    
    uint8_t *bytes = malloc(kCCKeySizeAES128);
    
    if (bytes)
    {
        if (SecRandomCopyBytes(kSecRandomDefault, kCCKeySizeAES128, bytes) == 0)
        {
            key = [GTMBase64 stringByEncodingBytes:bytes length:kCCKeySizeAES256];
        }
        free(bytes);
    }
    
    return key;
}


-(NSData*) transform:(CCOperation)encryptOrDecrypt data:(NSData*)inputData key:(NSData*)keyData
{
    CCCryptorStatus status = kCCSuccess;
    size_t bufferSize = [inputData length] + kCCBlockSizeAES128;
    size_t resultSize = 0;
    void *buffer = malloc(bufferSize * sizeof(uint8_t));
    memset(buffer, 0x0, bufferSize);
    
    status = CCCrypt(encryptOrDecrypt,
                     kCCAlgorithmAES128,
                     kCCOptionPKCS7Padding | kCCOptionECBMode,
                     [keyData bytes],
                     kCCKeySizeAES256,
                     NULL,
                     [inputData bytes],
                     [inputData length],
                     buffer,
                     bufferSize,
                     &resultSize);
    
    if (status == kCCSuccess)
    {
        NSMutableData *output = [NSMutableData dataWithBytesNoCopy:buffer length:resultSize];
        return output;
    }
    return nil;
}


-(NSString*) encryptMap:(NSMutableDictionary*)plainMap withKey:(NSString*)key
{
    NSMutableString *buffer = [[NSMutableString alloc] init];
    for (NSString *key in plainMap)
    {
        NSString *value = [plainMap valueForKey:key];
        [buffer appendFormat:@"&%@=%@", key, value];
    }
    
    // Add UUID to make the string unique.
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef newID = CFUUIDCreateString(NULL, theUUID);
    [buffer appendFormat:@"&%@", newID];
    CFRelease (newID);
    CFRelease(theUUID);
    
    NSString *result = [[self encrypt:buffer key:key] urlEncode];
    return result;
}

-(NSString*) encrypt:(NSString*)plainText key:(NSString*)key
{
    
    NSData *keyData    = [GTMBase64 decodeString:key];
    NSData *plainData  = [plainText dataUsingEncoding:NSISOLatin1StringEncoding];
    NSData *cipherData = [self transform:kCCEncrypt data:plainData key:keyData];
    return [GTMBase64 stringByEncodingData:cipherData];
}


-(NSString*) decrypt:(NSString*)cipherText key:(NSString*)key
{
    
    NSData *keyData    = [GTMBase64 decodeString:key];
    NSData *cipherData = [GTMBase64 decodeString:cipherText];
    NSData *plainData  = [self transform:kCCDecrypt data:cipherData key:keyData];  
    return [[NSString alloc] initWithData:plainData encoding:NSISOLatin1StringEncoding];
}  



-(NSString*)encryptString:(NSString*)string{
    // encryption with CCCrypt

    NSMutableData *myKey = [NSMutableData dataWithBytes:KEY_256_RGRPD length:kCCKeySizeAES128];
    NSMutableData *myIv = [NSMutableData dataWithBytes:IV64_RGRPD length:kCCKeySizeAES128];
    NSData *myData2 = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *myEnc = [NSMutableData dataWithLength:kCCKeySizeAES128+string.length];
    size_t myOut;
    
    CCCryptorStatus retEnc = CCCrypt(kCCEncrypt, kCCAlgorithmBlowfish, kCCOptionPKCS7Padding,
                                     myKey.bytes, myKey.length, myIv.bytes,
                                     myData2.bytes, myData2.length,
                                     myEnc.mutableBytes, myEnc.length, &myOut);
    
    if (retEnc == kCCSuccess) {
        // encryption succeeded
        myEnc.length = myOut;
    } else {
        // encryption failed
    }
    
    NSString *signature = [myEnc base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSLog(@"%@",signature);
    return signature;
}

-(NSString*)decryptString:(NSString*)encryptedString
{
    // Decrypt base 64 into message again
    NSData* iv = [[NSData alloc] initWithBase64EncodedString:IV64_RGRPD options:0];
    NSLog(@"IV : %@",[iv base64EncodedStringWithOptions:0]);
    
    NSString *sha256 = [[Utils sharedInstance] sha256:SALT_RGRPD];
    NSLog(@"%@",sha256);
    
    NSData* encryptedWithout64 = [[NSData alloc] initWithBase64EncodedString:encryptedString options:0];
    NSMutableData* decrypted = [NSMutableData dataWithLength:encryptedWithout64.length + kCCBlockSizeAES128];
    
    NSMutableData* hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    NSMutableData* key = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(SALT_RGRPD.UTF8String, (CC_LONG)strlen(SALT_RGRPD.UTF8String), hash.mutableBytes);
    CCKeyDerivationPBKDF(kCCPBKDF2, KEY_256_RGRPD.UTF8String, strlen(KEY_256_RGRPD.UTF8String), hash.bytes, hash.length, kCCPRFHmacAlgSHA256, 1000, key.mutableBytes, key.length);

    size_t bytesDecrypted = 0;
    if(CCCrypt(kCCDecrypt,
        kCCAlgorithmAES128,
        0x0000,
        key.bytes,
        key.length,
        iv.bytes,
        encryptedWithout64.bytes, encryptedWithout64.length,
               decrypted.mutableBytes, decrypted.length, &bytesDecrypted) != kCCSuccess){
        return @"";
    }
    
    NSString* encrypted64 = [[NSMutableData dataWithBytes:decrypted.mutableBytes length:bytesDecrypted] base64EncodedStringWithOptions:0];
    
    NSData* outputMessage = [NSMutableData dataWithBytes:decrypted.mutableBytes length:bytesDecrypted];
    NSString* outputString = [[NSString alloc] initWithData:outputMessage encoding:NSUTF8StringEncoding];
    NSLog(@"Decrypted : %@",outputString);
    return outputString;
}
@end
