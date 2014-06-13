//
//  LSTContactTableViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSContactTableViewCell.h"

@implementation LSContactTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:FALSE animated:FALSE];
    // Configure the view for the selected state
}

- (void) updateWithSelectionIndicator:(BOOL)selected
{
    if (!self.radioButton) {
        self.radioButton = [[UIView alloc] initWithFrame:CGRectMake(280, 16, 28, 28)];
        [self addSubview:self.radioButton];
    }
    self.radioButton.layer.cornerRadius = 14.0f;
    self.radioButton.backgroundColor = [UIColor redColor];
    
    if (selected) {
        self.radioButton.alpha = 1.0;
    } else {
        self.radioButton.alpha = 0.0;
    }
}
@end
