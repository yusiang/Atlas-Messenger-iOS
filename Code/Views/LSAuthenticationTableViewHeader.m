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
@property (nonatomic) UILabel *taglineLabel;

@end

@implementation LSAuthenticationTableViewHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        self.logoView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.logoView];

        self.taglineLabel = [[UILabel alloc] init];
        self.taglineLabel.numberOfLines = 0;
        self.taglineLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.taglineLabel.textAlignment = NSTextAlignmentCenter;
        self.taglineLabel.backgroundColor = [UIColor clearColor];
        self.taglineLabel.text = @"The open communications platform\nfor the internet.";
        self.taglineLabel.font = LYRUIMediumFont(12);
        [self addSubview:self.taglineLabel];

        [self setUpConstraints];
    }
    return self;
}

- (void)setShowsContent:(BOOL)showsContent
{
    _showsContent = showsContent;
    self.logoView.alpha = showsContent ? 1.0 : 0.0;
    self.taglineLabel.alpha = showsContent ? 1.0 : 0.0;
}

- (void)setUpConstraints
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
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.taglineLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.taglineLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:48]];
}

@end
