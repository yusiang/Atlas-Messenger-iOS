//
//  LYRContactCell.h
//  LayerSample
//
//  Created by Zac White on 8/22/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRContactPresenter.h"

@interface LYRContactCell : UITableViewCell

@property (readonly, nonatomic) UILabel *nameLabel;
@property (readonly, nonatomic) UILabel *secondaryLabel;

- (void)updateWithPresenter:(id<LYRContactPresenter>)presenter;

@end
