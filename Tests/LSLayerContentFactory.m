//
//  ATLLayerContentFactory.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/3/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSLayerContentFactory.h"
#import "LSUser.h"


@interface LSLayerContentFactory ()

@property (nonatomic) LYRClient *layerClient;

@end

@implementation LSLayerContentFactory

NSString *const ATLTestMessageText = @"Hi, this is a test!";

+ (instancetype)layerContentFactoryWithLayerClient:(LYRClient *)layerClient;
{
    return [[self alloc] initWithLayerClient:layerClient];
}

- (id)initWithLayerClient:(LYRClient *)layerClient
{
    self = [super init];
    if (self) {
        _layerClient = layerClient;
    }
    return self;
}

- (LYRConversation *)newConversationsWithParticipants:(NSSet *)participants
{
    LYRConversation *conversation = [self.layerClient newConversationWithParticipants:participants options:nil error:nil];
    [self sendMessagesToConversation:conversation number:10];
    return conversation;
}

- (void)sendMessagesToConversation:(LYRConversation *)conversation number:(NSUInteger)number
{
    for (int i = 0; i < number; i++) {
        LYRMessagePart *part = [LYRMessagePart messagePartWithText:ATLTestMessageText];
        NSError *error;
        LYRMessage *message = [self.layerClient newMessageWithParts:@[part] options:@{LYRMessageOptionsPushNotificationAlertKey: @"Test Push"} error:nil];
        [conversation sendMessage:message error:&error];
        if (error) {
            NSLog(@"Error sending messages");
        }
    }
}

@end