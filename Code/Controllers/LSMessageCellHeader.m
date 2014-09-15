//
//  LSMessageCellHeader.m
//  LayerSample
//
//  Created by Kevin Coleman on 7/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSMessageCellHeader.h"
#import "LYRUIConstants.h"

@interface LSMessageCellHeader ()

@property (nonatomic) UILabel *senderLabel;
@property (nonatomic) UILabel *timeStamp;

@end

@implementation LSMessageCellHeader

- (void)updateWithSenderName:(NSString *)senderName timeStamp:(NSDate *)timeStamp
{
    if (!self.senderLabel) {
        self.senderLabel = [[UILabel alloc] init];
        self.senderLabel.font = LSMediumFont(12);
        self.senderLabel.textColor = [UIColor lightGrayColor];
        self.senderLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.senderLabel];
    }
    if (senderName) {
       self.senderLabel.text = senderName;
    } else {
        self.senderLabel.text = nil;
    }
    [self.senderLabel sizeToFit];
    
    if (!self.timeStamp) {
        self.timeStamp = [[UILabel alloc] init];
        self.timeStamp.font = LSMediumFont(12);
        self.timeStamp.textColor = [UIColor lightGrayColor];
        self.timeStamp.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.timeStamp];
    }
    if (timeStamp) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd, hh:mma"];
        self.timeStamp.text =  [formatter stringFromDate:timeStamp];
    } else {
        self.timeStamp.text = nil;
    }
    [self.timeStamp sizeToFit];
    
    [self configureLayoutConstraints];
}


- (void)configureLayoutConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.senderLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:52]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.senderLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.timeStamp attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.timeStamp attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.senderLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:-16]];
}

@end
