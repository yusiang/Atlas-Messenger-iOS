//
//  LSTContactTableViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRContactTableViewCell.h"
#import "LSUIConstants.h"

@interface LYRContactTableViewCell ()

@property (nonatomic, strong) LSSelectionIndicator *selectionIndicator;
@property (nonatomic) BOOL isSelected;

@end

@implementation LYRContactTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSelectionIndicator];
        self.textLabel.font = LSMediumFont(14);
    
        [self setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    return self;
}
- (void)updateWithPresenter:(id<LYRContactPresenter>)presenter
{
    self.textLabel.text = [presenter nameText];
    self.detailTextLabel.text = [presenter subtitleText];
    self.imageView.image = [presenter avatarImage];
    [self setNeedsUpdateConstraints];
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
    if (!self.selectionIndicator) {
        self.selectionIndicator = [LSSelectionIndicator initWithDiameter:28];
        self.selectionIndicator.frame = CGRectMake(270, 6, 28, 28);
        self.selectionIndicator.accessibilityLabel = @"selectionIndicator";
        [self addSubview:self.selectionIndicator];
    }
}

- (void)updateWithSelectionIndicator:(BOOL)selected
{
    [self.selectionIndicator setSelected:selected];
}

@end
