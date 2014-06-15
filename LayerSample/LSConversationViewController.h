//
//  LSConversationViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRSampleConversation.h"
#import "LSLayerController.h"
#import "LSComposeView.h"

@interface LSConversationViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, LSComposeViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) LSLayerController *layerController;
@property (nonatomic, strong) LYRConversation *conversation;
@property (nonatomic, strong) NSArray *participantsForNewConversation;


@end
