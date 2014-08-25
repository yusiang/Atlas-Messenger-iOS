//
//  LSConversationCellPresenter.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "LSPersistenceManager.h"
#import "LYRConversationPresenter.h"
#import "LSUser.h"
#import "LSUtilities.h"

/**
 @abstract The `LSConversationCellPresenter` class models a conversation object and is used to present conversation information to the user interface
 */

@interface LSConversationCellPresenter : NSObject <LYRConversationCellPresenter>

///-------------------------------
/// @name Initializing a Presenter
///-------------------------------

+ (instancetype)presenterWithConversation:(LYRConversation *)conversation
                       persistanceManager:(LSPersistenceManager *)persistenceManager;

- (NSString *)titleText;

- (NSString *)dateText;

- (NSString *)lastMessageText;

- (UIImage *)avatarImage;

@property (nonatomic, strong) LYRConversation *conversation;

@end
