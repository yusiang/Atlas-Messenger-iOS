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

// SBW: You can probably use the standard cell selection here...
- (void)updateWithSelectionIndicator:(BOOL)selected;

@end
