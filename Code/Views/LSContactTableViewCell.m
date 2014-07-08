//
//  LSTContactTableViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSContactTableViewCell.h"
#import "LSUIConstants.h"

@interface LSContactTableViewCell ()

@property (nonatomic) BOOL isSelected;

@end

@implementation LSContactTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSelectionIndicator];
        self.textLabel.font = LSMediumFont(18);
        [self setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:FALSE animated:FALSE];
    if (selected && !self.isSelected) {
        [self updateWithSelectionIndicator:YES];
        self.isSelected = TRUE;
    } else if(!selected && !self.isSelected) {
        self.isSelected = FALSE;
        [self updateWithSelectionIndicator:FALSE];
    } else if (selected && self.isSelected) {
        self.isSelected = FALSE;
        [self updateWithSelectionIndicator:FALSE];
    }
}

- (void) addSelectionIndicator
{
    if (!self.radioButton) {
        self.radioButton = [LSSelectionIndicator initWithDiameter:28];
        self.radioButton.frame = CGRectMake(270, 10, 28, 28);
        self.radioButton.accessibilityLabel = @"selectionIndicator";
        [self addSubview:self.radioButton];
    }
}

- (void)updateWithSelectionIndicator:(BOOL)selected
{
    [self.radioButton setSelected:selected];
}

@end
