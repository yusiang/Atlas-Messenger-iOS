//
//  LSSelectionIndicator.h
//  LayerSample
//
//  Created by Kevin Coleman on 7/3/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSSelectionIndicator : UIView

+ (instancetype)initWithDiameter:(CGFloat)diameter;

- (void)setSelected:(BOOL)selected;

@end
