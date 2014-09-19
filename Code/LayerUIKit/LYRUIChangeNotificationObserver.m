//
//  LYRUIChangeNotificationObserver.m
//  Pods
//
//  Created by Kevin Coleman on 9/10/14.
//
//

#import "LYRUIChangeNotificationObserver.h"

@interface LYRUIChangeNotificationObserver ()

@property (nonatomic) NSArray *conversations;
@property (nonatomic) LYRConversation *conversation;
@property (nonatomic) LYRClient *layerClient;

@end

@implementation LYRUIChangeNotificationObserver

- (id)initWithClient:(LYRClient *)layerClient conversations:(NSArray *)conversations
{
    self = [super init];
    if (self) {
        
        _layerClient = layerClient;
        _conversations = conversations;
        
        if (conversations.count == 1) {
            _conversation = [conversations objectAtIndex:0];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerObjectsDidChangeNotification:) name:LYRClientObjectsDidChangeNotification object:layerClient];
        
    }
    return self;
}

- (id) init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
}


- (void)setConversations:(NSArray *)conversations
{
    _conversations = conversations;
}

- (void) didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification;
{
    [self.delegate observerWillChangeContent:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self processLayerChangeNotification:notification completion:^(NSMutableArray *conversationArray, NSMutableArray *messageArray) {
            [self processMessageChanges:messageArray completion:^{
                [self processConversationChanges:conversationArray completion:^{
                    [self.delegate observerDidChangeContent:self];
                }];
            }];
        }];
    });
}

- (void)processLayerChangeNotification:(NSNotification *)notification completion:(void(^)(NSMutableArray *conversationArray, NSMutableArray *messageArray))completion
{
    NSMutableArray *conversationArray = [[NSMutableArray alloc] init];
    NSMutableArray *messageArray = [[NSMutableArray alloc] init];
    
    NSArray *changes = [notification.userInfo objectForKey:LYRClientObjectChangesUserInfoKey];
    for (NSDictionary *change in changes) {
        
        if ([[change objectForKey:LYRObjectChangeObjectKey] isKindOfClass:[LYRConversation class]]) {
            [conversationArray addObject:change];
        }
        
        if ([[change objectForKey:LYRObjectChangeObjectKey]isKindOfClass:[LYRMessage class]]) {
            [messageArray addObject:change];
        }
    }
    completion(conversationArray, messageArray);
}

- (void) processConversationChanges:(NSMutableArray *)conversationChanges completion:(void(^)(void))completion
{
    [self dispatchChangeObject:nil atIndex:0 forChangeType:LYRObjectChangeTypeUpdate newIndexPath:0];
    completion();
}

- (void)processMessageChanges:(NSMutableArray *)messageChanges completion:(void(^)(void))completion
{
    for (int i = 0; i < messageChanges.count; i++) {
        NSDictionary *messageUpdate = [messageChanges objectAtIndex:i];
        LYRMessage *message = [messageUpdate objectForKey:LYRObjectChangeObjectKey];
        if ([self.conversations containsObject:message.conversation]) {
            LYRObjectChangeType updateKey = (LYRObjectChangeType)[[messageUpdate objectForKey:LYRObjectChangeTypeKey] integerValue];
            switch (updateKey) {
                case LYRObjectChangeTypeCreate:
                    [self handleMessageCreatation:message atIndex:i];
                    break;
                case LYRObjectChangeTypeUpdate:
                    [self handleMessageUpdate:message];
                    break;
                case LYRObjectChangeTypeDelete:
                    [self handleMessageDeletion:message];
                    break;
                default:
                    break;
            }
        }
    }
    completion();
}

#pragma mark
#pragma mark Conversation Notification Dispatch

- (void)handleConversationCreatation:(LYRConversation *)conversation atIndex:(NSUInteger)index
{
    [self dispatchChangeObject:conversation atIndex:0 forChangeType:LYRObjectChangeTypeCreate newIndexPath:index];
}

- (void)handleConversationUpdate:(LYRConversation *)conversation
{
    [self dispatchChangeObject:conversation atIndex:0 forChangeType:LYRObjectChangeTypeUpdate newIndexPath:0];
}

- (void)handleConversationDeletion:(LYRConversation *)conversation
{
    [self dispatchChangeObject:conversation atIndex:0 forChangeType:LYRObjectChangeTypeDelete newIndexPath:0];
}

#pragma mark
#pragma mark Message Notification Dispatch

- (void)handleMessageCreatation:(LYRMessage *)message atIndex:(NSUInteger)index
{
    [self dispatchChangeObject:message atIndex:0 forChangeType:LYRObjectChangeTypeCreate newIndexPath:index];
}

- (void)handleMessageUpdate:(LYRMessage *)message
{
    if (message.index) {
        [self dispatchChangeObject:message atIndex:message.index forChangeType:LYRObjectChangeTypeUpdate newIndexPath:0];
    }
}

- (void)handleMessageDeletion:(LYRMessage *)message
{
    if (message.index) {
        [self dispatchChangeObject:message atIndex:message.index forChangeType:LYRObjectChangeTypeUpdate newIndexPath:0];
    }
}

- (void)dispatchChangeObject:(id)object atIndex:(NSUInteger)index forChangeType:(LYRObjectChangeType)changeType newIndexPath:(NSUInteger)newIndexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate observer:self didChangeObject:object atIndex:index forChangeType:changeType newIndexPath:newIndexPath];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
