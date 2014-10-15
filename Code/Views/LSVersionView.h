//
//  LSVersionView.h
//  LayerSample
//
//  Created by Zac White on 7/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSVersionView : UIView

@property (readonly, nonatomic) UILabel *versionLabel;
@property (readonly, nonatomic) UILabel *buildLabel;
@property (readonly, nonatomic) UILabel *hostLabel;
@property (readonly, nonatomic) UILabel *userLabel;
@property (readonly, nonatomic) UILabel *deviceLabel;

@end
