//
//  LSConversationController.m
//  LayerSample
//
//  Created by Kevin Coleman on 7/18/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRConversationViewController.h"
#import "LSMessageCell.h"
#import "LSMessageCellPresenter.h"
#import "LSComposeView.h"
#import "LSUIConstants.h"
#import "LSMessageCellHeader.h"
#import "LSUtilities.h"

static double LSComposeViewHeight = 40;

@interface LYRConversationViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, LSComposeViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic) BOOL keyboardIsOnScreen;
@end

@implementation LYRConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    // Setup Collection View
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - LSComposeViewHeight)
                                             collectionViewLayout:flowLayout];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(10, 0, 20, 0);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = TRUE;
    self.collectionView.bounces = TRUE;
    self.collectionView.accessibilityLabel = @"collectionView";
    [self.view addSubview:self.collectionView];
    
    // Setup Compose View
    self.composeView = [[LSComposeView alloc] initWithFrame:CGRectMake(0, rect.size.height - 40, rect.size.width, LSComposeViewHeight)];
    self.composeView.delegate = self;
    [self.view addSubview:self.composeView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}


# pragma mark
# pragma mark Collection View Data Source
- (NSInteger)collectionView:(LYRCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource collectionView:collectionView numberOfItemsInSection:section];
}

- (NSInteger)numberOfSectionsInCollectionView:(LYRCollectionView *)collectionView
{
    return [self.dataSource numberOfSectionsInCollectionView:collectionView];
}

- (UICollectionViewCell *)collectionView:(LYRCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource collectionView:collectionView messageCellForItemAtIndexPath:indexPath];
}

#pragma mark
#pragma mark Collection View Delegate

- (void)collectionView:(LYRCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(LYRCollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [self.dataSource collectionView:collectionView heightForRowAtIndex:indexPath];
    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, height);
}

- (UICollectionReusableView *)collectionView:(LYRCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        [self.dataSource collectionView:collectionView viewForHeaderInSection:indexPath.section];
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        return [self.dataSource collectionView:collectionView viewForFooterInSection:indexPath.section];
    }
    return nil;
}

- (CGSize)collectionView:(LYRCollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGFloat height = [self.dataSource collectionView:collectionView heightForHeaderInSection:section];
    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, height);
}

- (CGSize)collectionView:(LYRCollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGFloat height = [self.dataSource collectionView:collectionView heightForFooterInSection:section];
    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, height);
}

#pragma mark
#pragma mark Keyboard Nofifications

- (void)keyboardWasShown:(NSNotification*)notification
{
    self.keyboardIsOnScreen = TRUE;
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y + kbSize.height)];
        self.composeView.frame = CGRectMake(self.composeView.frame.origin.x, self.composeView.frame.origin.y - kbSize.height, self.composeView.frame.size.width, self.composeView.frame.size.height);
    } completion:^(BOOL finished) {
        self.keyboardIsOnScreen = TRUE;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y - kbSize.height)];
        self.composeView.frame = CGRectMake(self.composeView.frame.origin.x, self.composeView.frame.origin.y + kbSize.height, self.composeView.frame.size.width, self.composeView.frame.size.height);
    } completion:^(BOOL finished) {
        self.keyboardIsOnScreen = FALSE;
        [self composeViewShouldRestFrame:nil];
    }];
}

#pragma mark
#pragma mark LSComposeViewDelegate

- (void)composeView:(LSComposeView *)composeView sendMessageWithText:(NSString *)text
{
    //TODO
}

- (void)composeView:(LSComposeView *)composeView sendMessageWithImage:(UIImage *)image
{
    //TODO
}

- (void)composeView:(LSComposeView *)composeView sendMessageLocation:(CLLocationCoordinate2D)location
{
    //TODO
}

- (void)composeViewShouldRestFrame:(LSComposeView *)composeView
{
    if (!self.keyboardIsOnScreen) {
        CGRect rect = [[UIScreen mainScreen] bounds];
        [self.composeView setFrame:CGRectMake(0, rect.size.height - 40, rect.size.width, 40)];
    }
}

- (void)composeView:(LSComposeView *)composeView setComposeViewHeight:(CGFloat)height
{
    if (height < 135) {
        CGRect rect = [[UIScreen mainScreen] bounds];
        CGFloat yOriginOffset = composeView.frame.size.height - height;
        [self.composeView setFrame:CGRectMake(0, composeView.frame.origin.y + yOriginOffset, rect.size.width, height)];
    }
}
@end