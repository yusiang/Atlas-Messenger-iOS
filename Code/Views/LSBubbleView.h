//
//  LSBubbleView.h
//  LayerSample
//
//  Created by Kevin Coleman on 7/7/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRMessagePart.h"
#import "LSMessageCellPresenter.h"

@interface LSBubbleView : UIView

- (void)updateViewWithPresenter:(LSMessageCellPresenter *)presenter;

- (void)displayArrowForSender;

- (void)displayArrowForRecipient;

@end
