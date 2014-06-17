//
//  LSConversationListVC.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSConversationViewController.h"

@class LSConversationListViewController;

@protocol LSConversationListViewControllerDelegate <NSObject>

- (void)logout;

@end

@interface LSConversationListViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) LSLayerController *layerController;
@property (nonatomic, weak) id<LSConversationListViewControllerDelegate> delegate;

@end
