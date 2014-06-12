//
//  LYRAuthenticationChallenge.m
//  
//
//  Created by Blake Watters on 5/16/14.
//
//

#import "LYRAuthenticationChallenge.h"
#import "LYRTransportErrors.h"

static NSString *const LYRTransportHeaderFieldPrefix = @"Layer ";
static NSString *const LYRTransportHeaderKeyRealm = @"realm";
static NSString *const LYRTransportHeaderKeyNonce = @"nonce";

static NSString *const LYRTransportHeaderFieldWWWAuthenticate = @"Www-Authenticate";
static NSString *const LYRAuthenticationChallengeHeaderKeyRealm = @"realm";
static NSString *const LYRAuthenticationChallengeHeaderKeyNonce = @"nonce";
static NSString *const LYRAuthenticationChallengeHeaderKeyAppID = @"app-id";

static NSDictionary *LYRDictionaryFromAuthorizationHeader(NSString *authorizationHeader)
{
    if (!authorizationHeader) [NSException raise:NSInvalidArgumentException format:@"Cannot parse authorization details from a `nil` authorization header."];
    NSScanner *scanner = [NSScanner scannerWithString:authorizationHeader];
    scanner.charactersToBeSkipped = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSMutableCharacterSet *letters = [NSMutableCharacterSet letterCharacterSet];
    [letters addCharactersInString:@"-_+./\\@"];
    [scanner scanString:LYRTransportHeaderFieldPrefix intoString:NULL];
    while (!scanner.isAtEnd) {
        NSString *key = nil;
        NSString *value = nil;
        [scanner scanCharactersFromSet:letters intoString:&key];
        [scanner scanString:@"=" intoString:NULL];
        [scanner scanString:@"\"" intoString:NULL];
        [scanner scanUpToString:@"\"" intoString:&value];
        [scanner scanString:@"\"," intoString:NULL];
        [scanner scanString:@" " intoString:NULL];
        if (!key || !value) continue;
        result[key] = value;
    }
    
    if (!result[LYRTransportHeaderKeyNonce]) [NSException raise:NSInternalInconsistencyException format:@"Couldn't find the 'nonce' value in the 401 response header!"];
    if (!result[LYRTransportHeaderKeyRealm]) [NSException raise:NSInternalInconsistencyException format:@"Couldn't find the 'realm' value in the 401 response header!"];
    
    return result;
}

@implementation LYRAuthenticationChallenge

+ (instancetype)authenticationChallengeWithResponse:(NSHTTPURLResponse *)response
{
    if (!response) return nil;
    if (response.statusCode != 401) return nil;
    
    NSString *authChallenge = [response allHeaderFields][LYRTransportHeaderFieldWWWAuthenticate];
    if (!authChallenge) [NSException raise:NSInternalInconsistencyException format:@"Got a 401 - unauthorized access error without the challenge!"];
    
    // Parse header field into a dictionary
    NSDictionary *challengeInfo = LYRDictionaryFromAuthorizationHeader(authChallenge);
    NSString *realm = challengeInfo[LYRAuthenticationChallengeHeaderKeyRealm];
    NSString *nonce = challengeInfo[LYRAuthenticationChallengeHeaderKeyNonce];
    return [[self alloc] initWithRealm:realm nonce:nonce URL:response.URL];
}

- (id)initWithRealm:(NSString *)realm nonce:(NSString *)nonce URL:(NSURL *)URL
{
    self = [super init];
    if (self) {
        _realm = realm;
        _nonce = nonce;
        _URL = URL;
    }
    return self;
}

- (NSError *)errorRespresentation
{
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Received an authentication challenge.",
                                NSURLErrorFailingURLErrorKey: self.URL,
                                @"realm": self.realm,
                                LYRTransportErrorAuthenticationNonceUserInfoKey: self.nonce };
    return [NSError errorWithDomain:LYRTransportErrorDomain code:LYRTransportErrorAuthenticationChallenge userInfo:userInfo];
}

@end
