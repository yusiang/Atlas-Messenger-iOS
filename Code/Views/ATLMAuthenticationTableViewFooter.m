//
//  ATLMAuthenticationTableViewFooter.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 8/26/14.
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

#import "ATLMAuthenticationTableViewFooter.h"
#import <Atlas/Atlas.h>

@interface ATLMAuthenticationTableViewFooter ()

@property (nonatomic) UIButton *primaryActionButton;
@property (nonatomic) UIButton *secondaryActionButton;
@property (nonatomic) UIButton *environmentButton;

@end

@implementation ATLMAuthenticationTableViewFooter

NSString *const ATLMLoginButtonText = @"Log In To Layer";
NSString *const ATLMRegisterButtonText = @"Create Account";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.primaryActionButton = [[UIButton alloc] init];
        [self.primaryActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.primaryActionButton setTitleColor:ATLLightGrayColor() forState:UIControlStateHighlighted];
        self.primaryActionButton.titleLabel.font = ATLMediumFont(16);
        self.primaryActionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.primaryActionButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.primaryActionButton.backgroundColor = ATLBlueColor();
        self.primaryActionButton.layer.cornerRadius = 4;
        self.primaryActionButton.clipsToBounds = YES;
        [self.primaryActionButton addTarget:self action:@selector(primaryActionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.primaryActionButton];
        
        self.secondaryActionButton = [[UIButton alloc] init];
        [self.secondaryActionButton setTitleColor:ATLBlueColor() forState:UIControlStateNormal];
        [self.secondaryActionButton setTitleColor:ATLBlueColor() forState:UIControlStateHighlighted];
        self.secondaryActionButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.secondaryActionButton.backgroundColor = [UIColor clearColor];
        self.secondaryActionButton.titleLabel.font = ATLMediumFont(16);
        self.secondaryActionButton.titleLabel.textColor = ATLBlueColor();
        self.secondaryActionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.secondaryActionButton addTarget:self action:@selector(secondaryActionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.secondaryActionButton];
        
        self.environmentButton = [[UIButton alloc] init];
        [self.environmentButton setTitle:@"Change Environment" forState:UIControlStateNormal];
        [self.environmentButton setTitleColor:ATLBlueColor() forState:UIControlStateNormal];
        [self.environmentButton setTitleColor:ATLBlueColor() forState:UIControlStateHighlighted];
        self.environmentButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.environmentButton.backgroundColor = [UIColor clearColor];
        self.environmentButton.titleLabel.font = ATLMediumFont(16);
        self.environmentButton.titleLabel.textColor = ATLBlueColor();
        self.environmentButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.environmentButton addTarget:self action:@selector(environmentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.environmentButton];
        
        [self setUpPrimaryButtonConstraints];
        [self setUpSecondaryButtonConstraints];
        [self setUpEnvironmentButtonConstraints];
    }
    return self;
}

#pragma mark - Constraints

- (void)setUpPrimaryButtonConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.primaryActionButton
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.primaryActionButton
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:40]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.primaryActionButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:260]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.primaryActionButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:40]];
}

- (void)setUpSecondaryButtonConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.secondaryActionButton
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.secondaryActionButton
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.primaryActionButton
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:40]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.secondaryActionButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:200]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.secondaryActionButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:40]];
}

- (void)setUpEnvironmentButtonConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.environmentButton
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.environmentButton
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.secondaryActionButton
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:20]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.environmentButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:200]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.environmentButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:40]];
}

#pragma mark - Accessors

- (void)setAuthenticationState:(ATLMAuthenticationState)authenticationState
{
    switch (authenticationState) {
        case ATLMAuthenticationStateRegister:
            [self.primaryActionButton setTitle:ATLMRegisterButtonText forState:UIControlStateNormal];
            [self.secondaryActionButton setTitle:ATLMLoginButtonText forState:UIControlStateNormal];
            break;
            
        case ATLMAuthenticationStateLogin:
            [self.primaryActionButton setTitle:ATLMLoginButtonText forState:UIControlStateNormal];
            [self.secondaryActionButton setTitle:ATLMRegisterButtonText forState:UIControlStateNormal];
            break;
    }
    _authenticationState = authenticationState;
}

#pragma mark - Actions

- (void)primaryActionButtonTapped
{
    [self.delegate authenticationTableViewFooter:self primaryActionButtonTappedWithAuthenticationState:self.authenticationState];
}

- (void)secondaryActionButtonTapped
{
    [UIView animateWithDuration:0.4 animations:^{
        self.primaryActionButton.titleLabel.alpha = 0.0;
        self.secondaryActionButton.titleLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (!finished) return;
        if (self.authenticationState == ATLMAuthenticationStateLogin) {
            self.authenticationState = ATLMAuthenticationStateRegister;
        } else {
            self.authenticationState = ATLMAuthenticationStateLogin;
        }
        [UIView animateWithDuration:0.4 animations:^{
            self.primaryActionButton.titleLabel.alpha = 1.0;
            self.secondaryActionButton.titleLabel.alpha = 1.0;
            [self.delegate authenticationTableViewFooter:self secondaryActionButtonTappedWithAuthenticationState:self.authenticationState];
        }];
    }];
}

- (void)environmentButtonTapped
{
    [self.delegate environmentButtonTappedForAuthenticationTableViewFooter:self];
}

@end
