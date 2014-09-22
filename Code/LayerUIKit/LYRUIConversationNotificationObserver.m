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

@property (nonatomic, strong) NSArray *conversations;

@end

@implementation LYRUIConversationNotificationObserver

- (instancetype)initWithLayerClient:(LYRClient *)layerClient conversations:(NSArray *)conversations
{
    self = [super init];
    if (self) {
        
        self.layerClient = layerClient;
        self.conversations = conversations;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerObjectsDidChangeNotification:)
                                                     name:LYRClientObjectsDidChangeNotification
                                                   object:layerClient];
        
    }
    return self;
}

- (id) init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
}

- (void) didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification;
{
    [self.delegate observerWillChangeContent:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self processLayerChangeNotification:notification completion:^(NSMutableArray *conversationArray) {
            [self processConversationChanges:conversationArray completion:^(NSArray *conversationChanges) {
                [self dispatchChanges:conversationChanges];
            }];
        }];
    });
}

- (void)processLayerChangeNotification:(NSNotification *)notification completion:(void(^)(NSMutableArray *conversationArray))completion
{
    NSMutableArray *conversationArray = [[NSMutableArray alloc] init];
    
    NSArray *changes = [notification.userInfo objectForKey:LYRClientObjectChangesUserInfoKey];
    for (NSDictionary *change in changes) {
        
        if ([[change objectForKey:LYRObjectChangeObjectKey] isKindOfClass:[LYRConversation class]]) {
            [conversationArray addObject:change];
        }
    }
    completion(conversationArray);
}

- (void) processConversationChanges:(NSMutableArray *)conversationChanges completion:(void(^)(NSArray *conversationChanges))completion
{
    NSMutableArray *changeObjects = [[NSMutableArray alloc] init];
    for (int i = 0; i < conversationChanges.count; i++) {
        NSDictionary *conversationChange = [conversationChanges objectAtIndex:i];
        LYRObjectChangeType changeType = (LYRObjectChangeType)[[conversationChange objectForKey:LYRObjectChangeTypeKey] integerValue];
        switch (changeType) {
            case LYRObjectChangeTypeCreate:
                [changeObjects addObject:[LYRUIDataSourceChange insertChangeWithIndex:i]];
                break;
            case LYRObjectChangeTypeUpdate:
                [changeObjects addObject:[LYRUIDataSourceChange updateChangeWithIndex:i]];
                break;
            case LYRObjectChangeTypeDelete:
                [changeObjects addObject:[LYRUIDataSourceChange deleteChangeWithIndex:i]];
                break;
            default:
                break;
        }
    }
    completion(changeObjects);
}

- (void)dispatchChanges:(NSArray *)changes
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate observer:self updateWithChanges:changes];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
