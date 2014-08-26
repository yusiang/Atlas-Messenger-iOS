//
//  LSTContactTableViewCell.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSSelectionIndicator.h"
#import "LYRContactPresenter.h"

@interface LYRContactTableViewCell : UITableViewCell

- (void)updateWithPresenter:(id<LYRContactPresenter>)presenter;

- (void)updateWithSelectionIndicator:(BOOL)selected;

@end
