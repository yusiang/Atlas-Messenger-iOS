//
//  LSTContactTableViewCell.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSContactTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *radioButton;

- (void) updateWithSelectionIndicator:(BOOL)selected;

- (void) displaySelectionIndicator;
@end
