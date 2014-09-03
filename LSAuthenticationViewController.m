//
//  LSAuthenticationViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSAuthenticationViewController.h"
#import "LYRUIConstants.h"

@interface LSAuthenticationViewController ()

@property (nonatomic) LSAuthState authState;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *primaryActionButton;
@property (nonatomic, strong) UIButton *secondaryActionButton;

@end

@implementation LSAuthenticationViewController

static NSString *LSLoginText = @"Login To Layer";
static NSString *LSRegisterText = @"Create Account";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = LSLighGrayColor();
    
    self.logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.logoImageView];
    
    self.textView = [[UITextView alloc] init];
    self.textView.editable = NO;
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.textAlignment = NSTextAlignmentCenter;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.text = @"The open communications platform for the internet.";
    self.textView.font = LSMediumFont(12);
    [self.view addSubview:self.textView];

    self.primaryActionButton = [[UIButton alloc] init];
    [self.primaryActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.primaryActionButton setTitleColor:LSLighGrayColor() forState:UIControlStateHighlighted];
    self.primaryActionButton.titleLabel.font = LSMediumFont(16);
    self.primaryActionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.primaryActionButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.primaryActionButton.backgroundColor = LSBlueColor();
    self.primaryActionButton.layer.cornerRadius = 4;
    self.primaryActionButton.clipsToBounds = TRUE;
    [self.primaryActionButton addTarget:self action:@selector(primaryActionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.primaryActionButton];
    
    self.secondaryActionButton = [[UIButton alloc] init];
    [self.secondaryActionButton setTitleColor:LSBlueColor() forState:UIControlStateNormal];
    [self.secondaryActionButton setTitleColor:LSBlueColor() forState:UIControlStateHighlighted];
    self.secondaryActionButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.secondaryActionButton.backgroundColor = [UIColor clearColor];
    self.secondaryActionButton.titleLabel.font = LSMediumFont(16);
    self.secondaryActionButton.titleLabel.textColor = LSBlueColor();
    self.secondaryActionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.secondaryActionButton addTarget:self action:@selector(secondaryActionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.secondaryActionButton];
    
    [self updateViewConstraints];
    [self setAuthState:LSAuthStateLogin];
}

- (void)setAuthState:(LSAuthState)authState
{
    switch (authState) {
        case LSAuthStateRegister:
            [self.primaryActionButton setTitle:LSRegisterText forState:UIControlStateNormal];
            [self.secondaryActionButton setTitle:LSLoginText forState:UIControlStateNormal];
            break;
        case LSAuthStateLogin:
            [self.primaryActionButton setTitle:LSLoginText forState:UIControlStateNormal];
            [self.secondaryActionButton setTitle:LSRegisterText forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    _authState = authState;
}

- (void)updateViewConstraints
{
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logoImageView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logoImageView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:100]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.textView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.textView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.logoImageView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-20]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.textView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:40]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.textView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:210]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.primaryActionButton
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.primaryActionButton
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:300]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.primaryActionButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:260]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.primaryActionButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:40]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.secondaryActionButton
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.secondaryActionButton
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.primaryActionButton
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:40]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.secondaryActionButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:200]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.secondaryActionButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:40]];
    [super updateViewConstraints];
}

- (void)primaryActionButtonTapped
{
    
}

- (void)secondaryActionButtonTapped
{
    
}



@end
