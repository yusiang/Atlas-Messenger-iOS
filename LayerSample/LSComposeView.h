//
//  LSComposeView.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSComposeView;

@protocol LSComposeViewDelegate <NSObject>

- (void)sendMessageWithText:(NSString *)text;

@end

@interface LSComposeView : UIView <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, weak) id<LSComposeViewDelegate>delegate;

@end
