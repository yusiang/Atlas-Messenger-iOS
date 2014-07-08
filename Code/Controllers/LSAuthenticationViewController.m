//
//  LSHomeViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSAuthenticationViewController.h"
#import "LSConversationListViewController.h"
#import "LSButton.h"
#import "LSUIConstants.h"
#import "LSLoginViewController.h"
#import "LSRegistrationViewController.h"

@interface LSAuthenticationViewController ()

@property (nonatomic) UIImageView *logo;
@property (nonatomic) LSButton *registerButton;
@property (nonatomic) LSButton *loginButton;

@end

@implementation LSAuthenticationViewController

- (void)viewDidLoad
{
    NSAssert(self.APIManager, @"APIManager cannot be nil");
    NSAssert(self.layerClient, @"layerClient cannot be nil");
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Home";
    self.accessibilityLabel = @"Home Screen";
    
    self.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.logo.translatesAutoresizingMaskIntoConstraints = FALSE;
    [self.view addSubview:self.logo];
    
    self.registerButton = [[LSButton alloc] initWithText:@"Register"];
    self.registerButton.translatesAutoresizingMaskIntoConstraints = FALSE;
    self.registerButton.backgroundColor = LSBlueColor();
    self.registerButton.alpha = 0.8;
    self.registerButton.textLabel.textColor = [UIColor whiteColor];
    [self.registerButton addTarget:self action:@selector(registerTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.registerButton];
    
    self.loginButton =[[LSButton alloc] initWithText:@"Login"];
    self.loginButton.layer.borderColor = LSBlueColor().CGColor;
    self.loginButton.textLabel.textColor = LSBlueColor();
    self.loginButton.backgroundColor = [UIColor whiteColor];
    self.loginButton.alpha = 0.8;
    [self.loginButton addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginButton];
    
    [self setupLayoutConstraints];
}

- (void)loadView
{
    [super loadView];
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:applicationFrame];
    imageView.userInteractionEnabled = TRUE;
    imageView.image = [UIImage imageNamed:@"winter"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.view = imageView;
}

- (void)setupLayoutConstraints
{
    //**********Logo Constraints**********//
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logo
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logo
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:-100]];

    
    //**********Register Button Constraints**********//
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.registerButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.9
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.registerButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.08
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.registerButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.registerButton
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:140]];
    
    //**********Login Button Constraints**********//
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.loginButton
                                                          attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.9
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.loginButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.08
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.loginButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.loginButton
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.registerButton
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:20]];
    
}
- (void)registerTapped
{
    LSRegistrationViewController *registrationViewController = [[LSRegistrationViewController alloc] init];
    [registrationViewController setCompletionBlock:^(LSUser *user) {
        if (user) {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }];
    self.navigationController.navigationBarHidden = FALSE;
    registrationViewController.APIManager = self.APIManager;
    [self.navigationController pushViewController:registrationViewController animated:YES];
}

- (void)loginTapped
{
    LSLoginViewController *loginViewController = [[LSLoginViewController alloc] init];
    [loginViewController setCompletionBlock:^(LSUser *user) {
        if (user) {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }];
    self.navigationController.navigationBarHidden = FALSE;
    loginViewController.APIManager = self.APIManager;
    [self.navigationController pushViewController:loginViewController animated:YES];
}

@end
