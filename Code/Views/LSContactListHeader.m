//
//  LSContactListHeader.m
//  LayerSample
//
//  Created by Kevin Coleman on 7/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSContactListHeader.h"
#import "LSUIConstants.h"

@interface LSContactListHeader ()

@property (nonatomic) UIView *bottomBar;
@property (nonatomic) UILabel *keyLabel;

@end

@implementation LSContactListHeader

- (id)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];

        self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(10, 30, 300, 1)];
        self.bottomBar.backgroundColor = LSGrayColor();
        [self addSubview:self.bottomBar];

        
        self.keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 50, 20)];
        self.keyLabel.font = LSMediumFont(14);
        self.keyLabel.text = key;
        self.keyLabel.textColor = LSGrayColor();
        [self addSubview:self.keyLabel];
    }
    return self;
}

@end
