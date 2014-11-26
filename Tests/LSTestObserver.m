//
//  LSTestObserver.m
//  LayerSample
//
//  Created by Kevin Coleman on 11/15/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSTestObserver.h"

@interface LSTestObserver ()

@property (nonatomic) LYRClient *client;
@property (nonatomic) LYRObjectChangeType changeType;
@property (nonatomic) Class changeClass;
@property (nonatomic) NSString *property;

@end

@implementation LSTestObserver

+ (instancetype)initWithClass:(Class)class changeType:(LYRObjectChangeType)changeType property:(NSString *)property;
{
    return [[self alloc] initWithClass:class changeType:changeType property:property];
}

- (id)initWithClass:(Class)class changeType:(LYRObjectChangeType)changeType property:(NSString *)property;
{
    self = [super init];
    if (self) {
        
        _changeClass = class;
        _changeType = changeType;
        _property = property;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveLayerObjectsDidChangeNotification:)
                                                     name:LYRClientObjectsDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
}


- (void)didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification;
{
    NSArray *changes = [notification.userInfo valueForKey:LYRClientObjectChangesUserInfoKey];
    for (NSDictionary *change in changes) {
        id changeObject = [change objectForKey:LYRObjectChangeObjectKey];
        if ([changeObject isKindOfClass:[LYRConversation class]]) {
            [self conversationChange:change];
        } else {
            [self messageChange:change];
        }
    }
}

- (void)conversationChange:(NSDictionary *)conversationChange
{
    BOOL class = [self.changeClass isSubclassOfClass:[LYRConversation class]];
    BOOL property = [[conversationChange objectForKey:LYRObjectChangePropertyKey] isEqualToString:self.property];
    BOOL changeType =  ([[conversationChange objectForKey:LYRObjectChangeTypeKey] integerValue] == self.changeType);
    if (changeType && property && class) {
        NSLog(@"%@", conversationChange);
        [self.delegate testObserver:self objectDidChange:conversationChange];
    }
}

- (void)messageChange:(NSDictionary *)messageChange
{
    BOOL class = [self.changeClass isSubclassOfClass:[LYRMessage class]];
    BOOL property = [[messageChange objectForKey:LYRObjectChangePropertyKey] isEqualToString:self.property];
    BOOL changeType =  ([[messageChange objectForKey:LYRObjectChangeTypeKey] integerValue] == self.changeType);
    if (changeType && property) {
        [self.delegate testObserver:self objectDidChange:messageChange];
    }
}

@end
