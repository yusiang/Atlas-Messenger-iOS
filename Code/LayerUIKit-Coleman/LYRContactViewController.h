//
//  LYRContactViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRContactCellPresenter.h"
#import "LYRContactHeaderCell.h"
#import "LYRContactDetailCell.h"
#import "LYRContactActionCell.h"

typedef enum {
    LYRContactViewCellPhoneType,
    LYRContactViewCellEmailType,
    LYRContactViewCellActionType
}LYRContactViewCellType;

typedef enum {
    LYRContactViewCellInsertType,
    LYRContactViewCellUpdateType,
    LYRContactViewCellDeleteType
}LYRContactViewEditType;

@class LYRContactViewController;

@protocol LYRContactViewControllerDataSource <NSObject>

@required

- (id<LYRContactPresenter>)presenterForContactViewController:(LYRContactViewController *)viewController;

@end

@protocol LYRContactViewControllerDelegate <NSObject>

- (void)contactViewController:(LYRContactViewController *)viewController didSelectCellWithType:(LYRContactViewCellType)cellType atIndex:(NSUInteger)index;

- (void)contactViewController:(LYRContactViewController *)viewController didEditCellWithType:(LYRContactViewCellType)cellType editType:(LYRContactViewEditType)editType atIndex:(NSUInteger)index;

@end

@interface LYRContactViewController : UITableViewController

@property (nonatomic, strong) id<LYRContactViewControllerDataSource>dataSource;

@property (nonatomic, strong) id<LYRContactViewControllerDelegate>delegate;

//@property (nonatomic, strong) LSUser *contact;

@end
