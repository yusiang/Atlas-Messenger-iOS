//
//  LSStyleValue1TableViewCell.m
//  LayerSample
//
//  Created by Ben Blakley on 1/13/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "LSStyleValue1TableViewCell.h"

@implementation LSStyleValue1TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    // We don't use the passed style because when used with -[UITableView registerClass:forCellReuseIdentifier:] this method will always be called with the default style and that is not the one we want.
    return [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
}

@end
