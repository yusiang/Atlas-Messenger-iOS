//
//  LSMessagePartCellPresenter.h
//  LayerSample
//
//  Created by Kevin Coleman on 7/8/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRMessagePart.h"
#import "LSPersistenceManager.h"

@interface LSMessagePartCellPresenter : NSObject

@property (nonatomic, strong) LYRMessagePart *message;
@property (nonatomic) BOOL shouldShowSenderImage;
@property (nonatomic) BOOL shouldShowSenderLabel;

///-------------------------------
/// @name Initializing a Presenter
///-------------------------------

+ (instancetype)presenterWithMessage:(LYRMessagePart *)messagePart persistanceManager:(LSPersistenceManager *)persistenceManager;

- (BOOL)messageWasSentByAuthenticatedUser;

- (NSString *)labelForMessageSender;

- (UIImage *)imageForMessageSender;

- (BOOL)shouldShowAvatar;


@end
