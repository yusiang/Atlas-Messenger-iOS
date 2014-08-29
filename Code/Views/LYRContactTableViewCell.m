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

@property (nonatomic, strong) UIControl *selectionIndicator;
@property (nonatomic) BOOL isSelected;

@end

@implementation LYRContactTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = LSMediumFont(14);
        
        [self setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    return self;
}
- (void)updateWithPresenter:(id<LYRContactCellPresenter>)presenter
{
    self.textLabel.text = [presenter nameText];
    self.detailTextLabel.text = [presenter subtitleText];
    self.imageView.image = [presenter avatarImage];
    [self setNeedsUpdateConstraints];
}

- (void)updateWithSelectionIndicator:(UIControl *)selectionIndicator
{
    self.selectionIndicator = selectionIndicator;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:FALSE animated:FALSE];
    if (selected && !self.isSelected) {
        [self.selectionIndicator setHighlighted:YES];
        self.isSelected = TRUE;
    } else if(!selected && !self.isSelected) {
        self.isSelected = FALSE;
        [self.selectionIndicator setHighlighted:NO];
    } else if (selected && self.isSelected) {
        self.isSelected = FALSE;
        [self.selectionIndicator setHighlighted:NO];
    }
}

@end

