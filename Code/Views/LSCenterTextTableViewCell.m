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
        [self addSubview:self.centerTextLabel];
        
    }
    return self;
}

- (void)setCenterText:(NSString *)text
{
    self.centerTextLabel.text = text;
    [self.centerTextLabel sizeToFit];
    [self updateLabelConstraints];
}

- (void)updateLabelConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.centerTextLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.centerTextLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
    
}
@end
