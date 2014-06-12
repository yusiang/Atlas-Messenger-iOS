//
//  LYRCSR.m
//  LayerKit
//
//  Created by Blake Watters on 3/28/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <UIKit/UIDevice.h>
#import "LYRCSR.h"
#import "LYRBase64Serialization.h"

extern NSString *LYRHTTPUserAgentString(void);

static size_t LYRASN1EncodingLength(unsigned char * buf, size_t length) {
    
    // encode length in ASN.1 DER format
    if (length < 128) {
        buf[0] = length;
        return 1;
    }
    
    size_t i = (length / 256) + 1;
    buf[0] = i + 0x80;
    for (size_t j = 0 ; j < i; ++j) {
        buf[i - j] = length & 0xFF;
        length = length >> 8;
    }
    
    return i + 1;
}

NSString *LYRPublicKeyDataWithPKC1Wrapping(NSData *publicKeyData)
{
    unsigned char builder[15];
    NSMutableData *encKey = [NSMutableData new];
    NSUInteger bitstringEncLength;
    
    // When we get to the bitstring - how will we encode it?
    if ([publicKeyData length] + 1  < 128) {
        bitstringEncLength = 1;
    } else {
        bitstringEncLength = (([publicKeyData length] + 1) / 256) + 2;
    }
    
    static const unsigned char _encodedRSAEncryptionOID[15] = {
        /* Sequence of length 0xd made up of OID followed by NULL */
        0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00
    };
    
    // Overall we have a sequence of a certain length
    builder[0] = 0x30;    // ASN.1 encoding representing a SEQUENCE
    // Build up overall size made up of -
    // size of OID + size of bitstring encoding + size of actual key
    size_t i = sizeof(_encodedRSAEncryptionOID) + 2 + bitstringEncLength + [publicKeyData length];
    size_t j = LYRASN1EncodingLength(&builder[1], i);
    [encKey appendBytes:builder length:j +1];
    
    // First part of the sequence is the OID
    [encKey appendBytes:_encodedRSAEncryptionOID
                 length:sizeof(_encodedRSAEncryptionOID)];
    
    // Now add the bitstring
    builder[0] = 0x03;
    j = LYRASN1EncodingLength(&builder[1], [publicKeyData length] + 1);
    builder[j+1] = 0x00;
    [encKey appendBytes:builder length:j + 2];
    
    // Now the actual key
    [encKey appendData:publicKeyData];
    
    // Now translate the result to a Base64 string
    return [encKey base64EncodedStringWithOptions:0];
}

@interface LYRCSR ()
@property (nonatomic, strong) LYRKeyPair *keyPair;
@end

@implementation LYRCSR

+ (instancetype)CSRWithKeyPair:(LYRKeyPair *)keyPair
{
    return [[self alloc] initWithKeyPair:keyPair];
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Failed to call designated initializer. Call `CSRWithPublicKeyData:` instead"
                                 userInfo:nil];
}

- (id)initWithKeyPair:(LYRKeyPair *)keyPair
{
    if (!keyPair) [NSException raise:NSInvalidArgumentException format:@"`keyPair` cannot be `nil`."];
    self = [super init];
    if (self) {
        self.keyPair = keyPair;
    }
    return self;
}

- (NSDictionary *)header
{
    return @{ @"typ": @"JWS",
              @"cty": @"layer-csr;v=1",
              @"alg": @"RS256" };
}

- (NSDictionary *)payload
{
    return @{ @"uat": LYRHTTPUserAgentString(),
              @"prn": [[[UIDevice currentDevice] identifierForVendor] UUIDString],
              @"pka": @"RSA",
              @"pky": LYRPublicKeyDataWithPKC1Wrapping(self.keyPair.publicKeyData) };
}

- (NSString *)JWSStringRepresentation
{
    NSError *error = nil;
    NSData *headerJSON = [NSJSONSerialization dataWithJSONObject:self.header options:0 error:&error];
    if (!headerJSON) return nil;
    NSString *base64Header = [LYRBase64Serialization base64URLEncodedStringWithoutPaddingFromData:headerJSON];
    
    NSData *payloadJSON = [NSJSONSerialization dataWithJSONObject:self.payload options:0 error:&error];
    if (!payloadJSON) return nil;
    NSString *base64Payload = [LYRBase64Serialization base64URLEncodedStringWithoutPaddingFromData:payloadJSON];
    
    NSString *signingInput = [NSString stringWithFormat:@"%@.%@", base64Header, base64Payload];
    NSData *signature = [self.keyPair signatureForData:[signingInput dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    if (!signature) return nil;
    
    NSString *base64Signature = [LYRBase64Serialization base64URLEncodedStringWithoutPaddingFromData:signature];
    return [signingInput stringByAppendingFormat:@".%@", base64Signature];
}

@end
