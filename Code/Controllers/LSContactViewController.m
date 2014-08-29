//
//  LSContactViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSContactViewController.h"
#import "LSContactPresenter.h"

@interface LSContactViewController () <LYRContactViewControllerDataSource, LYRContactViewControllerDelegate>

@end

@implementation LSContactViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
}
    
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSAssert(self.user, @"Must have a user");
}

- (id<LYRContactPresenter>)presenterForContactViewController:(LYRContactViewController *)viewController
{
    return [LSContactPresenter presenterWithContact:self.user];
}

- (void)contactViewController:(LYRContactViewController *)viewController didSelectCellWithType:(LYRContactViewCellType)cellType atIndex:(NSUInteger)index
{
    switch (cellType) {
        case LYRContactViewCellEmailType:
            // Handle Sending Email
            break;
        case LYRContactViewCellPhoneType:
            // Handle Sending Email
            break;
        case LYRContactViewCellActionType:
            // Handle Action
            break;
        default:
            break;
    }
}

- (void)contactViewController:(LYRContactViewController *)viewController didEditCellWithType:(LYRContactViewCellType)cellType editType:(LYRContactViewEditType)editType atIndex:(NSUInteger)index
{
    switch (cellType) {
        case LYRContactViewCellEmailType:
            switch (editType) {
                case LYRContactViewCellInsertType:
                    // Persist an email
                    break;
                case LYRContactViewCellUpdateType:
                    // Edit an email
                    break;
                case LYRContactViewCellDeleteType:
                    // Delete an email
                    break;
                default:
                    break;
            }
            break;
        case LYRContactViewCellPhoneType:
            switch (editType) {
                case LYRContactViewCellInsertType:
                    // Persit a phone number
                    break;
                case LYRContactViewCellUpdateType:
                    // Change a phone number
                    break;
                case LYRContactViewCellDeleteType:
                    // Delete a phone number
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}



@end
