//
//  LSConversationViewCell.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LSConversationCellPresenter.h"
#import "LSUser.h"

@interface LYRConversationCell : UITableViewCell

- (void)updateWithPresenter:(id<LYRConversationCellPresenter>)presenter;

@end
