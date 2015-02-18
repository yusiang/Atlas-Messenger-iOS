//
//  ATLMSplashView.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 9/24/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "ATLMSplashView.h"

@interface ATLMSplashView ()

@property (nonatomic) UIImageView *logoImageView;
@property (nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation ATLMSplashView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        self.logoImageView.center = CGPointMake(self.center.x, self.center.y - 40);
        self.logoImageView.alpha = 0.10;
        [self addSubview:self.logoImageView];
       
        self.spinner = [[UIActivityIndicatorView alloc] init];
        self.spinner.center = CGPointMake(self.center.x, self.center.y + 40);
        self.spinner.color = [UIColor blackColor];
        [self.spinner startAnimating];
        [self addSubview:self.spinner];
    }
    return self;
}

@end
