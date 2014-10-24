//
//  LSSettingsHeaderView.h
//  LayerSample
//
//  Created by Kevin Coleman on 10/23/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSUser.h"

@interface LSSettingsHeaderView : UIView

+ (instancetype)headerViewWithUser:(LSUser *)user;

- (void)updateConnectedStateWithString:(NSString *)string;

@end
