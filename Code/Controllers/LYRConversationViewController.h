//
//  LSConversationController.h
//  LayerSample
//
//  Created by Kevin Coleman on 7/18/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LYRCollectionView.h"
#import "LYRMessageCell.h"
#import "LSComposeView.h"

@class LYRConversationViewController;

@protocol LYRConversationViewControllerDataSource <NSObject>

- (NSInteger)collectionView:(LYRCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

- (NSInteger)numberOfSectionsInCollectionView:(LYRCollectionView *)collectionView;

- (LYRMessageCell *)collectionView:(LYRCollectionView *)collectionView messageCellForItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGSize)collecitonView:(LYRCollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)collectionView:(LYRCollectionView *)collectionView shouldDisplaySenderImageAtIndexPath:(NSIndexPath *)path;

- (BOOL)collectionView:(LYRCollectionView *)collectionView shouldDisplaySenderLabelForSection:(NSUInteger)section;

- (CGFloat)collectionView:(LYRCollectionView *)collectionView heightForRowAtIndex:(NSIndexPath *)indexPath;

- (CGFloat)collectionView:(LYRCollectionView *)collectionView heightForHeaderInSection:(NSUInteger)section;

- (CGFloat)collectionView:(LYRCollectionView *)collectionView heightForFooterInSection:(NSUInteger)section;

- (UICollectionReusableView *)collectionView:(LYRCollectionView *)collectionView viewForHeaderInSection:(NSInteger)section;

- (UICollectionReusableView *)collectionView:(LYRCollectionView *)collectionView viewForFooterInSection:(NSInteger)section;

@end

@protocol LYRConversationViewControllerDelegate <NSObject>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface LYRConversationViewController : UIViewController

@property (nonatomic, weak) id<LYRConversationViewControllerDataSource>dataSource;

@property (nonatomic, weak) id<LYRConversationViewControllerDelegate>delegate;

@property (nonatomic, weak) LSComposeView *composeView;
@end
