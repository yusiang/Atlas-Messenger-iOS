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

@interface LSMessageCellPresenter : NSObject

@property (nonatomic, strong) LSPersistenceManager *persistenceManager;
@property (nonatomic, strong) LYRMessage *message;

- (BOOL)messageWasSentByAuthenticatedUser;

- (NSString *)senderLabel;

@end
