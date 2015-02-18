//
//  ATLMSplashView.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 9/24/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
