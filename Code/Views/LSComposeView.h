//
//  LSComposeView.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSButton.h"

@class LSComposeView;

@protocol LSComposeViewDelegate <NSObject>

- (void)sendMessageWithText:(NSString *)text;
- (void)sendMessageWithImage:(UIImage *)image;
- (void)cameraTapped;

@end

@interface LSComposeView : UIView <UITextViewDelegate>

@property (nonatomic, strong) UIView *backingTextView;
@property (nonatomic, strong) UITextView *textVIew;
@property (nonatomic, strong) LSButton *cameraButton;
@property (nonatomic, strong) LSButton *sendButton;
@property (nonatomic, weak) id<LSComposeViewDelegate>delegate;

- (void)updateWithImage:(UIImage *)image;

@end
