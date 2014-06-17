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

// SBW: You can declare protocols on the class extension inside the implementation file. The collection view protocols is
// an implementation detail and doesn't need to be exposed publicly.
@interface LSConversationListViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) LSLayerController *layerController;
@property (nonatomic, weak) id<LSConversationListViewControllerDelegate> delegate;

@end
