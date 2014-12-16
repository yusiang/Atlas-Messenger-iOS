//
//  LSAuthenticationTableViewHeader.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSAuthenticationTableViewHeader.h"
#import "LYRUIConstants.h"

@interface LSAuthenticationTableViewHeader ()

@property (nonatomic) UIImageView *logoView;
@property (nonatomic) UITextView *textView;

@end

@implementation LSAuthenticationTableViewHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        self.logoView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.logoView];
        self.textView = [[UITextView alloc] init];
        self.textView.editable = NO;
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        self.textView.textAlignment = NSTextAlignmentCenter;
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.text = @"The open communications platform for the internet.";
        self.textView.font = LYRUIMediumFont(12);
        [self addSubview:self.textView];
        [self updateConstraints];
    }
    return self;
}

- (void)setShowsContent:(BOOL)showsContent
{
    if (!showsContent) {
        self.logoView.alpha = 0.0;
        self.textView.alpha = 0.0;
    }
}

- (void)updateConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.logoView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.logoView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:48]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:40]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:210]];
    [super updateConstraints];
}

@end
