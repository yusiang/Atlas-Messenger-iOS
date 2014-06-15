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

@property (nonatomic, strong) LYRClient *client;

- (void)initializeLayerClientWithUserIdentifier:(NSString *)identifier completion:(void (^)(NSError *error))completion;

-(void)authenticateLayerClientWithCompletion:(void (^)(NSError * error))completion;

-(void)sendMessage:(NSString *)messageText inConversation:(LYRConversation *)conversation;

-(LYRConversation *)conversationForParticipants:(NSArray *)particiapnts;

@end
