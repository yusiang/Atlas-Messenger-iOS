//
//  LYRUIComposeViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 9/5/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LYRUIComposeViewController;

@protocol LYRUIComposeViewControllerDelegate <NSObject>

- (void)composeViewController:(LYRUIComposeViewController *)composeViewController didTapSendButtonWithText:(NSString *)text;

@end

@interface LYRUIComposeViewController : UIViewController

@property (nonatomic, strong) UIButton *leftControlItem;

@property (nonatomic, strong) UIButton *rightControlItem;

@property (nonatomic, strong) UITextView *textInputView;

@property (nonatomic, weak) id<LYRUIComposeViewControllerDelegate>delegate;

@end
