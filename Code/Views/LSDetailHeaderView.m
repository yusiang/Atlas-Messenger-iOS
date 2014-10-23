//
//  LSDetailHeaderView.m
//  
//
//  Created by Kevin Coleman on 10/23/14.
//
//

#import "LSDetailHeaderView.h"

@interface LSDetailHeaderView ()

@property (nonatomic) UILabel *titleLabel;

@end

@implementation LSDetailHeaderView

+ (instancetype)initWithTitle:(NSString *)title
{
    return [[self alloc] initWithTitle:title];
}

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.text = title;
        [_titleLabel sizeToFit];
        [self addSubview:_titleLabel];
    }
    [self updateConstraints];
    return self;
}

- (void)updateConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    [super updateConstraints];
}

@end
