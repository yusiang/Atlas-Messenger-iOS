//
//  LYRUIConversationListNotificationObserver.m
//  Pods
//
//  Created by Kevin Coleman on 9/20/14.
//
//

#import "LYRUIConversationNotificationObserver.h"
#import "LYRUIDataSourceChange.h"

@interface LYRUIConversationNotificationObserver ()

@property (nonatomic) NSArray *conversations;
@property (nonatomic) NSArray *tempIdentifiers;

@end

@implementation LYRUIConversationNotificationObserver

- (instancetype)initWithLayerClient:(LYRClient *)layerClient conversations:(NSArray *)conversations
{
    self = [super init];
    if (self) {
        self.layerClient = layerClient;
        self.conversations = conversations;
        self.conversationIdentifiers = [self refreshConversations];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerObjectsDidChangeNotification:)
                                                     name:LYRClientObjectsDidChangeNotification
                                                   object:layerClient];
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
}

- (NSArray *)refreshConversations
{
    NSSet *conversations = [self.layerClient conversationsForIdentifiers:nil];
    NSArray *sortedConversations = [conversations sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastMessage.sentAt" ascending:NO]]];
    return [sortedConversations valueForKeyPath:@"identifier"];
}

- (void)didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification;
{
    [self.delegate observerWillChangeContent:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self processLayerChangeNotification:notification completion:^(NSMutableArray *conversationArray) {
            if (conversationArray.count > 0) {
                [self processConversationChanges:conversationArray completion:^(NSArray *conversationChanges) {
                    [self dispatchChanges:conversationChanges];
                }];
            }
        }];
    });
}

- (void)processLayerChangeNotification:(NSNotification *)notification completion:(void(^)(NSMutableArray *conversationArray))completion
{
    NSMutableArray *conversationArray = [[NSMutableArray alloc] init];
    NSArray *changes = [notification.userInfo objectForKey:LYRClientObjectChangesUserInfoKey];
    //NSLog(@"%@", changes);
    for (NSDictionary *change in changes) {
        if ([[change objectForKey:LYRObjectChangeObjectKey] isKindOfClass:[LYRConversation class]]) {
            [conversationArray addObject:change];
        }
    }
    completion(conversationArray);
}

- (void)processConversationChanges:(NSMutableArray *)conversationChanges completion:(void(^)(NSArray *conversationChanges))completion
{
    self.tempIdentifiers = [self refreshConversations];
    NSMutableArray *changeObjects = [[NSMutableArray alloc] init];
    for (NSDictionary *conversationChange in conversationChanges) {
        LYRConversation *conversation = [conversationChange objectForKey:LYRObjectChangeObjectKey];
        NSUInteger conversationIndex = [self.conversationIdentifiers indexOfObject:conversation.identifier];
        LYRObjectChangeType changeType = (LYRObjectChangeType)[[conversationChange objectForKey:LYRObjectChangeTypeKey] integerValue];
        switch (changeType) {
            case LYRObjectChangeTypeCreate:
                [changeObjects addObject:[LYRUIDataSourceChange insertChangeWithIndex:conversationIndex]];
                break;
                
            case LYRObjectChangeTypeUpdate:
                if ([[conversationChange objectForKey:LYRObjectChangePropertyKey] isEqualToString:@"lastMessage"]) {
                    NSUInteger newIndex = [self.tempIdentifiers indexOfObject:conversation.identifier];
                    [changeObjects addObject:[LYRUIDataSourceChange moveChangeWithOldIndex:conversationIndex newIndex:newIndex]];
                } else {
                    [changeObjects addObject:[LYRUIDataSourceChange updateChangeWithIndex:conversationIndex]];
                }
                break;
                
            case LYRObjectChangeTypeDelete:
                [changeObjects addObject:[LYRUIDataSourceChange deleteChangeWithIndex:conversationIndex]];
                break;
                
            default:
                break;
        }
    }
    self.conversationIdentifiers = self.tempIdentifiers;
    completion(changeObjects);
}

- (void)dispatchChanges:(NSArray *)changes
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate observer:self updateWithChanges:changes];
        [self.delegate observerdidChangeContent:self];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
