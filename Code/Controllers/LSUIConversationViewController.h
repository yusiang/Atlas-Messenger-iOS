//
//  LSUIConversationViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 9/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIConversationViewController.h"
#import "LSPersistenceManager.h"

@interface LSUIConversationViewController : LYRUIConversationViewController

@property (nonatomic, strong) LSPersistenceManager *persistenceManager;

@end
