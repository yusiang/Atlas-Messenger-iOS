//
//  LYRUIParticipantTableViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIParticipantTableViewCell.h"
#import "LSUIConstants.h"

@interface LYRUIParticipantTableViewCell ()

@property (nonatomic, strong) UIControl *selectionIndicator;
@property (nonatomic) BOOL isSelected;

@end

@implementation LYRUIParticipantTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.textLabel.font = LSMediumFont(14);
        [self setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    return self;
}

- (void)presentParticipant:(id<LYRUIParticipant>)participant
{
    self.textLabel.text = [participant fullName];
    [self setNeedsUpdateConstraints];
}

- (void)updateWithSelectionIndicator:(UIControl *)selectionIndicator
{
    self.selectionIndicator = selectionIndicator;
}

@end
