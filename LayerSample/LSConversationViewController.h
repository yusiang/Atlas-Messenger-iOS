//
//  LSConversationViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRSampleConversation.h"

@interface LSConversationViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) LYRSampleConversation *conversation;

@end
