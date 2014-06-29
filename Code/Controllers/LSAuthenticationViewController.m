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

@property (nonatomic) UILabel *titleLabel;
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
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = FALSE;
    self.titleLabel.text = @"Layer Chat";
    self.titleLabel.font = [UIFont fontWithName:[LSUIConstants layerMediumFont] size:42];
    self.titleLabel.textColor = [LSUIConstants layerBlueColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleLabel sizeToFit];
    [self.view addSubview:self.titleLabel];
    
    self.registerButton = [[LSButton alloc] initWithText:@"Register"];
    self.registerButton.translatesAutoresizingMaskIntoConstraints = FALSE;
    self.registerButton.backgroundColor = [LSUIConstants layerBlueColor];
    [self.registerButton addTarget:self action:@selector(registerTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.registerButton];
    
    self.loginButton =[[LSButton alloc] initWithText:@"Login"];
    self.loginButton.translatesAutoresizingMaskIntoConstraints = FALSE;
    self.loginButton.borderColor = [LSUIConstants layerBlueColor];
    self.loginButton.textColor = [LSUIConstants layerBlueColor];
    self.loginButton.backgroundColor = [UIColor whiteColor];
    [self.loginButton addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginButton];

    self.titleLabel.center = CGPointMake(self.view.center.x, self.view.center.y - 100);
    
    self.registerButton.frame = CGRectMake(0, 0, 280, 60);
    self.registerButton.center = CGPointMake(self.view.center.x, 380);
    
    self.loginButton.frame = CGRectMake(0, 0, 280, 60);
    self.loginButton.center = CGPointMake(self.view.center.x, 460);
}

- (void)registerTapped
{
    LSRegistrationViewController *registrationViewController = [[LSRegistrationViewController alloc] init];
    [registrationViewController setCompletionBlock:^(LSUser *user) {
        if (user) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    registrationViewController.APIManager = self.APIManager;
    [self.navigationController pushViewController:registrationViewController animated:YES];
}

- (void)loginTapped
{
    LSLoginViewController *loginViewController = [[LSLoginViewController alloc] init];
    [loginViewController setCompletionBlock:^(LSUser *user) {
        if (user) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    loginViewController.APIManager = self.APIManager;
    [self.navigationController pushViewController:loginViewController animated:YES];
}

@end
