//
//  ATLMStyleValue1TableViewCell.m
//  Atlas Messenger
//
//  Created by Ben Blakley on 1/13/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "ATLMStyleValue1TableViewCell.h"

@implementation ATLMStyleValue1TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    // We don't use the passed style because when used with -[UITableView registerClass:forCellReuseIdentifier:] this method will always be called with the default style and that is not the one we want.
    return [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
}

@end
