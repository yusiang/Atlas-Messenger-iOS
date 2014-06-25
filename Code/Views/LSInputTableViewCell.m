//
//  LSInputTableViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSInputTableViewCell.h"
#import "LSUIConstants.h"
@implementation LSInputTableViewCell

#define kLayerColor     [UIColor colorWithRed:36.0f/255.0f green:166.0f/255.0f blue:225.0f/255.0f alpha:1.0]
#define kLayerFont      @"Avenir-Medium"

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setText:(NSString *)text
{
    if (!self.textField) {
        self.textField = [[UITextField alloc] init];
    }
    self.textField.placeholder = text;
    self.textField.font = [UIFont fontWithName:[LSUIConstants layerMediumFont] size:18];
    self.textField.textColor = [UIColor darkGrayColor];
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.textField sizeToFit];
    self.textField.frame = CGRectMake(20, 14, self.frame.size.width - 20, self.textField.frame.size.height);
    [self addSubview:self.textField];
}

// SBW: What's up with this?
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:FALSE animated:FALSE];
}

@end
