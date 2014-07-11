//
//  LSContactListHeader.m
//  LayerSample
//
//  Created by Kevin Coleman on 7/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSContactListHeader.h"
#import "LSUIConstants.h"

@interface LSContactListHeader ()

@property (nonatomic) UIView *bottomBar;
@property (nonatomic) UILabel *keyLabel;

@end

@implementation LSContactListHeader

- (id)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];

        self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(10, 30, 300, 1)];
//        self.bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
        self.bottomBar.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.bottomBar];

        
        self.keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 50, 20)];
//        self.keyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.keyLabel.font = LSBoldFont(14);
        self.keyLabel.text = key;
        self.keyLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:self.keyLabel];
    }
    return self;
}

- (void)configureConstraints
{
//    self.translatesAutoresizingMaskIntoConstraints = NO;
// 
//    //**********Key Label**********//
//    // Left Margin
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.keyLabel
//                                                     attribute:NSLayoutAttributeCenterY
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self
//                                                     attribute:NSLayoutAttributeCenterY
//                                                    multiplier:1.0
//                                                      constant:0]];
//    // Top Margin
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.keyLabel
//                                                     attribute:NSLayoutAttributeCenterX
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self
//                                                     attribute:NSLayoutAttributeCenterX
//                                                    multiplier:0.5
//                                                      constant:0]];
////    //
////    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.keyLabel
////                                                     attribute:NSLayoutAttributeWidth
////                                                     relatedBy:NSLayoutRelationEqual
////                                                        toItem:self
////                                                     attribute:NSLayoutAttributeWidth
////                                                    multiplier:.5
////                                                      constant:0]];
//    
//    //**********Key Label**********//
//    // Left Margin
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar
//                                                     attribute:NSLayoutAttributeLeft
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self
//                                                     attribute:NSLayoutAttributeLeft
//                                                    multiplier:1.0
//                                                      constant:10]];
//    // Top Margin
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar
//                                                     attribute:NSLayoutAttributeTop
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.keyLabel
//                                                     attribute:NSLayoutAttributeTop
//                                                    multiplier:1.0
//                                                      constant:4]];
//    // Right Margin
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar
//                                                     attribute:NSLayoutAttributeWidth
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self
//                                                     attribute:NSLayoutAttributeRight
//                                                    multiplier:1.0
//                                                      constant:10]];
//}
}
@end
