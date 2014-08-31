//
//  LSTContactTableViewCell.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRSelectionIndicator.h"
#import "LYRContactCellPresenter.h"

@interface LYRContactTableViewCell : UITableViewCell

- (void)updateWithPresenter:(id<LYRContactCellPresenter>)presenter;

- (void)updateWithSelectionIndicator:(UIControl *)selectionIndicator;

@end

