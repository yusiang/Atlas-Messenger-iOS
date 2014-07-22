//
//  LSMessageCellHeader.m
//  LayerSample
//
//  Created by Kevin Coleman on 7/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSMessageCellHeader.h"
#import "LSUIConstants.h"

@interface LSMessageCellHeader ()

@property (nonatomic) UILabel *label;
@property (nonatomic) UILabel *timeStamp;

@end

@implementation LSMessageCellHeader

- (void)updateWithSenderName:(NSString *)senderName timeStamp:(NSDate *)timeStamp
{
    if (!self.label) {
        self.label = [[UILabel alloc] init];
        self.label.font = LSMediumFont(12);
        self.label.textColor = LSGrayColor();
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.label];
    }
    if (senderName) {
       self.label.text = senderName;
    } else {
        self.label.text = nil;
    }
    [self.label sizeToFit];
    
    if (!self.timeStamp) {
        self.timeStamp = [[UILabel alloc] init];
        self.timeStamp.font = LSBoldFont(12);
        self.timeStamp.textColor = LSGrayColor();
        self.timeStamp.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.timeStamp];
    }
    if (timeStamp) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy hh:mma"];
        self.timeStamp.text =  [formatter stringFromDate:timeStamp];
    } else {
        self.timeStamp.text = nil;
    }
    [self.timeStamp sizeToFit];
    
    [self configureLayoutConstraints];
}


- (void)configureLayoutConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:72]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-6]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.timeStamp attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.timeStamp attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.label attribute:NSLayoutAttributeTop multiplier:1.0 constant:-16]];
}

@end
