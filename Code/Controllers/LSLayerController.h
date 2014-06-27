//
//  LSLayerController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>

@interface LSLayerController : NSObject <LYRClientDelegate, NSURLSessionDelegate>

- (id)initWithClient:(LYRClient *)client;
@property (nonatomic, readonly) LYRClient *client;

- (void)authenticateUser:(NSString *)userID completion:(void (^)(NSError *error))completion;

- (void)sendMessage:(NSString *)messageText inConversation:(LYRConversation *)conversation;

- (void)sendImage:(UIImage *)image inConversation:(LYRConversation *)conversation;

- (LYRConversation *)conversationForParticipants:(NSArray *)particiapnts;

- (void)logout;

@end
