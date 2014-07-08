//
//  LSMessageCellPresenter.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/30/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSPersistenceManager.h"
#import "LYRMessage.h"

/**
 @abstract The `LSMessageCellPresenter` class models a message object and is used to present message information to the user interface
 */


@interface LSMessageCellPresenter : NSObject

@property (nonatomic, strong) LYRMessage *message;
@property (nonatomic) BOOL shouldShowSenderImage;
@property (nonatomic) BOOL shouldShowSenderLabel;

///-------------------------------
/// @name Initializing a Presenter
///-------------------------------

+ (instancetype)presenterWithMessage:(LYRMessage *)message indexPath:(NSIndexPath *)indexPath persistanceManager:(LSPersistenceManager *)persistenceManager;

- (BOOL)messageWasSentByAuthenticatedUser;

- (NSString *)labelForMessageSender;

- (UIImage *)imageForMessageSender;

- (NSUInteger)indexForPart;

@end
