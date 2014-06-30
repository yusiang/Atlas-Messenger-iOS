//
//  LSConversationCellPresenter.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSPersistenceManager.h"
#import "LYRConversation.h"
#import "LYRMessage.h"
#import "LSUser.h"

/**
 @abstract The `LSConversationCellPResent` class models a conversation object and is used to present conversation information to the user.
 */

@interface LSConversationCellPresenter : NSObject

@property (nonatomic, strong) LYRConversation *conversation;
@property (nonatomic, strong) LSPersistenceManager *persistenceManager;
@property (nonatomic, strong) NSOrderedSet *mesages;
@property (nonatomic, strong) NSArray *participants;
@property (nonatomic, strong) NSMutableArray *participantNames;

- (NSString *)conversationLabel;

- (UIImage *)imageForAuthenticatedUser;



@end
