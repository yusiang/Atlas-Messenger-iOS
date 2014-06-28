//
//  LSHomeViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSHomeViewController.h"
#import "LSConversationListViewController.h"
#import "SVProgressHUD.h"
#import "LSUserManager.h"
#import "LSButton.h"
#import "LSUIConstants.h"

@interface LSHomeViewController ()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) LSButton *registerButton;
@property (nonatomic) LSButton *loginButton;

@end

@implementation LSHomeViewController

- (void)viewDidLoad
{
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

#pragma mark
#pragma mark Button Actions

- (void)registerTapped
{
    LSRegistrationTableViewController *registerVC = [[LSRegistrationTableViewController alloc] init];
    [registerVC setCompletionBlock:^(LSUser *user) {
        if (user) {
            [self.navigationController popViewControllerAnimated:YES];
            [self presentConversationViewController];
        }
    }];
    registerVC.authenticationManager = self.authenticationManager;
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (void)loginTapped
{
    LSLoginTableViewController *loginVC = [[LSLoginTableViewController alloc] init];
    [loginVC setCompletionBlock:^(LSUser *user) {
        if (user) {
            [self.navigationController popViewControllerAnimated:YES];
            [self presentConversationViewController];
        }
    }];
    loginVC.authenticationManager = self.authenticationManager;
    [self.navigationController pushViewController:loginVC animated:YES];
}

#pragma mark
#pragma mark Layer Authentication Methods

- (void)presentConversationViewController
{
    LSConversationListViewController *conversationListViewController = [[LSConversationListViewController alloc] init];
    conversationListViewController.layerClient = self.layerClient;
    UINavigationController *conversationController = [[UINavigationController alloc] initWithRootViewController:conversationListViewController];
    [self presentViewController:conversationController animated:YES completion:nil];
}

@end
