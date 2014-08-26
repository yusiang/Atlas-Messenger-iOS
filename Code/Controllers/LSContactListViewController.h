//
//  LSContactListViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRContactListViewController.h"
#import "LSApplicationController.h"

@class  LSContactListViewController;

@protocol LSContactListViewControllerDelegate <NSObject>

@required

- (void)contactsSelectionViewController:(LSContactListViewController *)contactsSelectionViewController didSelectContacts:(NSSet *)contacts;

- (void)contactsSelectionViewControllerDidCancel:(LSContactListViewController *)contactsSelectionViewController;

@end

@interface LSContactListViewController : LYRContactListViewController

@property (nonatomic, strong) LSApplicationController *applicationController;

@property (nonatomic, strong) id<LSContactListViewControllerDelegate> selectionDelegate;

@end
