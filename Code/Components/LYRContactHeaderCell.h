//
//  LYRContactHeaderCell.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRContactPresenter.h"

@interface LYRContactHeaderCell : UITableViewCell

- (void)updateWithPresenter:(id<LYRContactPresenter>)presenter;

@end
