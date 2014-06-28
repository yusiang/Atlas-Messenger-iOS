//
//  LSConversationViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LSLayerController.h"
#import "LSComposeView.h"

@interface LSConversationViewController : UIViewController

@property (nonatomic, strong) LYRClient *layerClient;
@property (nonatomic, strong) LYRConversation *conversation;
@property (nonatomic, strong) NSArray *participantsForNewConversation; // SBW: This appears to be unused


@end
