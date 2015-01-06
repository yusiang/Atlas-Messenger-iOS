//
//  LSAuthenticationTableViewFooter.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSAuthenticationTableViewFooter.h"
#import "LYRUIConstants.h"

@interface LSAuthenticationTableViewFooter ()

@property (nonatomic) UIButton *primaryActionButton;
@property (nonatomic) UIButton *secondaryActionButton;
@property (nonatomic) UIButton *environmentButton;

@end

@implementation LSAuthenticationTableViewFooter

static NSString *const LSLoginText = @"Login To Layer";
static NSString *const LSRegisterText = @"Create Account";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.primaryActionButton = [[UIButton alloc] init];
        [self.primaryActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.primaryActionButton setTitleColor:LYRUILightGrayColor() forState:UIControlStateHighlighted];
        self.primaryActionButton.titleLabel.font = LYRUIMediumFont(16);
        self.primaryActionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.primaryActionButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.primaryActionButton.backgroundColor = LYRUIBlueColor();
        self.primaryActionButton.layer.cornerRadius = 4;
        self.primaryActionButton.clipsToBounds = TRUE;
        [self.primaryActionButton addTarget:self action:@selector(primaryActionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.primaryActionButton];
        
        self.secondaryActionButton = [[UIButton alloc] init];
        [self.secondaryActionButton setTitleColor:LYRUIBlueColor() forState:UIControlStateNormal];
        [self.secondaryActionButton setTitleColor:LYRUIBlueColor() forState:UIControlStateHighlighted];
        self.secondaryActionButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.secondaryActionButton.backgroundColor = [UIColor clearColor];
        self.secondaryActionButton.titleLabel.font = LYRUIMediumFont(16);
        self.secondaryActionButton.titleLabel.textColor = LYRUIBlueColor();
        self.secondaryActionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.secondaryActionButton addTarget:self action:@selector(secondaryActionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.secondaryActionButton];
        
        self.environmentButton = [[UIButton alloc] init];
        [self.environmentButton setTitle:@"Change Environment" forState:UIControlStateNormal];
        [self.environmentButton setTitleColor:LYRUIBlueColor() forState:UIControlStateNormal];
        [self.environmentButton setTitleColor:LYRUIBlueColor() forState:UIControlStateHighlighted];
        self.environmentButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.environmentButton.backgroundColor = [UIColor clearColor];
        self.environmentButton.titleLabel.font = LYRUIMediumFont(16);
        self.environmentButton.titleLabel.textColor = LYRUIBlueColor();
        self.environmentButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.environmentButton.layer.borderColor = LYRUIBlueColor().CGColor;
        self.environmentButton.layer.cornerRadius = 1.0;
        [self.environmentButton addTarget:self action:@selector(environmentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.environmentButton];
        
        [self updateConstraints];
    }
    return self;
}

- (void)updateConstraints
{
    //********** Primary Button **********//
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
    
    //********** Secondary Button **********//
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
    
    //********** Environment Button **********//
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
    
    [super updateConstraints];
}

- (void)setAuthenticationState:(LSAuthenticationState)authenticationState
{
    switch (authenticationState) {
        case LSAuthenticationStateRegister:
            [self.primaryActionButton setTitle:LSRegisterText forState:UIControlStateNormal];
            [self.secondaryActionButton setTitle:LSLoginText forState:UIControlStateNormal];
            break;
            
        case LSAuthenticationStateLogin:
            [self.primaryActionButton setTitle:LSLoginText forState:UIControlStateNormal];
            [self.secondaryActionButton setTitle:LSRegisterText forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    _authenticationState = authenticationState;
}

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
        if (self.authenticationState == LSAuthenticationStateLogin) {
            self.authenticationState = LSAuthenticationStateRegister;
        } else {
            self.authenticationState = LSAuthenticationStateLogin;
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
