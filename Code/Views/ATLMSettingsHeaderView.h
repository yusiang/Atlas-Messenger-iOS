//
//  ATLMSettingsHeaderView.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 10/23/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATLMUser.h"

@interface ATLMSettingsHeaderView : UIView

+ (instancetype)headerViewWithUser:(ATLMUser *)user;

- (void)updateConnectedStateWithString:(NSString *)string;

@end
