//
//  LSCenterTextTableViewCell.m
//  
//
//  Created by Kevin Coleman on 10/24/14.
//
//

#import "LSCenterTextTableViewCell.h"

@implementation LSCenterTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.centerTextLabel = [[UILabel alloc] init];
        self.centerTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.centerTextLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.centerTextLabel];
        
        [self setUpConstraints];
    }
    return self;
}

- (void)setCenterText:(NSString *)text
{
    self.centerTextLabel.text = text;
}

- (void)setUpConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.centerTextLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:10.0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.centerTextLabel
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:-10.0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.centerTextLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
    
}
@end
