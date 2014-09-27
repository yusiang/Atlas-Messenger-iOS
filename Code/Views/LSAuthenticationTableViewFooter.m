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
@property (nonatomic) UIButton *cancelButton;

@end

@implementation LSAuthenticationTableViewFooter

static NSString *const LSLoginText = @"Login To Layer";
static NSString *const LSRegisterText = @"Create Account";
static NSString *const LSCancelText = @"Or, Cancel";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.primaryActionButton = [[UIButton alloc] init];
        [self.primaryActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.primaryActionButton setTitleColor:LSLighGrayColor() forState:UIControlStateHighlighted];
        self.primaryActionButton.titleLabel.font = LSLightFont(16);
        self.primaryActionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.primaryActionButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.primaryActionButton.backgroundColor = LSBlueColor();
        self.primaryActionButton.layer.cornerRadius = 4;
        self.primaryActionButton.clipsToBounds = TRUE;
        [self.primaryActionButton addTarget:self action:@selector(primaryActionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.primaryActionButton];
        
        self.secondaryActionButton = [[UIButton alloc] init];
        [self.secondaryActionButton setTitleColor:LSBlueColor() forState:UIControlStateNormal];
        [self.secondaryActionButton setTitleColor:LSBlueColor() forState:UIControlStateHighlighted];
        self.secondaryActionButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.secondaryActionButton.backgroundColor = [UIColor clearColor];
        self.secondaryActionButton.titleLabel.font = LSLightFont(16);
        self.secondaryActionButton.titleLabel.textColor = LSBlueColor();
        self.secondaryActionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.secondaryActionButton addTarget:self action:@selector(secondaryActionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.secondaryActionButton];
        
//        self.cancelButton = [[UIButton alloc] init];
//        self.cancelButton.backgroundColor = [UIColor redColor];
//        [self.cancelButton setTitleColor:LSBlueColor() forState:UIControlStateNormal];
//        [self.cancelButton setTitleColor:LSBlueColor() forState:UIControlStateHighlighted];
//        self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
//        self.cancelButton.titleLabel.font = LSMediumFont(12);
//        self.cancelButton.titleLabel.textColor = LSBlueColor();
//        self.cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//        [self.cancelButton addTarget:self action:@selector(cancelButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:self.cancelButton];
        
        [self updateConstraints];
    }
    return self;
}

- (void)updateConstraints
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
    
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton
//                                                     attribute:NSLayoutAttributeCenterX
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self
//                                                     attribute:NSLayoutAttributeCenterX
//                                                    multiplier:1.0
//                                                      constant:0]];
//    
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton
//                                                     attribute:NSLayoutAttributeTop
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.secondaryActionButton
//                                                     attribute:NSLayoutAttributeBottom
//                                                    multiplier:1.0
//                                                      constant:40]];
//    
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton
//                                                     attribute:NSLayoutAttributeWidth
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:nil
//                                                     attribute:NSLayoutAttributeNotAnAttribute
//                                                    multiplier:1.0
//                                                      constant:200]];
//    
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton
//                                                     attribute:NSLayoutAttributeHeight
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:nil
//                                                     attribute:NSLayoutAttributeNotAnAttribute
//                                                    multiplier:1.0
//                                                      constant:40]];
    
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
    [self.cancelButton setTitle:LSCancelText forState:UIControlStateNormal];
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
        [UIView animateWithDuration:0.4 animations:^{
            if (self.authenticationState == LSAuthenticationStateLogin) {
                [self setAuthenticationState:LSAuthenticationStateRegister];
            } else {
                [self setAuthenticationState:LSAuthenticationStateLogin];
            }
            self.primaryActionButton.titleLabel.alpha = 1.0;
            self.secondaryActionButton.titleLabel.alpha = 1.0;
            [self.delegate authenticationTableViewFooter:self secondaryActionButtonTappedWithAuthenticationState:self.authenticationState];
        }];
    }];
}

- (void)cancelButtonWasTapped
{
    [self.delegate cancelButtonTappedForAuthenticationTableViewFooter:self];
}

@end
