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

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) LSButton *registerButton;
@property (nonatomic, strong) LSButton *loginButton;

@end

@implementation LSHomeViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = @"Home";
        self.accessibilityLabel = @"Home Screen";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeTitleText];
    [self initializeRegistrationButton];
    [self initializeLoginButton];
    [self configureLayoutConstraints];
}

#pragma mark
#pragma mark Private Instance Methodds

- (void)initializeTitleText
{
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = FALSE;
    self.titleLabel.text = @"Layer Chat";
    self.titleLabel.font = [UIFont fontWithName:[LSUIConstants layerMediumFont] size:42];
    self.titleLabel.textColor = [LSUIConstants layerBlueColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleLabel sizeToFit];
    [self.view addSubview:self.titleLabel];
}

- (void)initializeRegistrationButton
{
    self.registerButton = [[LSButton alloc] initWithText:@"Register"];
    self.registerButton.translatesAutoresizingMaskIntoConstraints = FALSE;
    self.registerButton.backgroundColor = [LSUIConstants layerBlueColor];
    [self.registerButton addTarget:self action:@selector(registerTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.registerButton];
}

- (void)initializeLoginButton
{
    self.loginButton =[[LSButton alloc] initWithText:@"Login"];
    self.loginButton.translatesAutoresizingMaskIntoConstraints = FALSE;
    self.loginButton.borderColor = [LSUIConstants layerBlueColor];
    self.loginButton.textColor = [LSUIConstants layerBlueColor];
    self.loginButton.backgroundColor = [UIColor whiteColor];
    [self.loginButton addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginButton];
}

- (void)configureLayoutConstraints
{
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
    registerVC.delegate = self;
    [self.navigationController pushViewController:registerVC animated:TRUE];
}

- (void)loginTapped
{
    LSLoginTableViewController *loginVC = [[LSLoginTableViewController alloc] init];
    loginVC.delegate = self;
    [self.navigationController pushViewController:loginVC animated:TRUE];
}

#pragma mark
#pragma mark LSRegistrationViewControllerDelegate Methods

- (void)registrationSuccess
{
    [self authenticateLayerClient];
}

#pragma mark
#pragma mark LSLoginViewControllerDelegate Methods

- (void)loginSuccess
{
    [self authenticateLayerClient];
}

#pragma mark
#pragma mark Layer Authentication Methods

- (void)authenticateLayerClient
{
    [SVProgressHUD show];
    [self.layerController authenticateUser:[LSUserManager loggedInUserID] completion:^(NSError *error) {
        if (!error) {
            NSLog(@"Layer Client Started");
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self presentConversationViewController];
            });
        }
    }];
}

- (void)presentConversationViewController
{
    LSConversationListViewController *conversationListViewController = [[LSConversationListViewController alloc] init];
    conversationListViewController.layerController = self.layerController;
    
    UINavigationController *conversationController = [[UINavigationController alloc] initWithRootViewController:conversationListViewController];
    
    [self presentViewController:conversationController animated:TRUE completion:^{
        NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
        [navigationArray removeObjectAtIndex: 1];
        self.navigationController.viewControllers = navigationArray;
    }];
}



//=========Auto Layout Exploration Code=========//



- (void)autoLayoutExploration
{
    NSDictionary *views = @{@"titleLabel" : self.titleLabel,
                            @"registerButton" : self.registerButton,
                            @"loginButton" : self.loginButton};
    
    NSDictionary *metrics = @{@"sidePadding":@40.0,
                              @"bottomPadding" : @80.0};
    
    //    // Header view fills the width of its superview
    //    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-sidePadding-[titleLabel]-sidePadding-|" options:0 metrics:metrics views:views]];
    //
    //    // Header view is pinned to the top of the superview
    //    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-bottomPadding-[titleLabel]-bottomPadding-|" options:0 metrics:metrics views:views]];
    
    // Headline and image horizontal layout
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-sidePadding-[registerButton]-sidePadding-|" options:0 metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-sidePadding-[loginButton]-sidePadding-|" options:0 metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sidePadding-[registerButton]-sidePadding-[loginButton]-sidePadding-|" options:0 metrics:metrics views:views]];
    //
    //    // Headline and byline vertical layout - spacing at least zero between the two
    //    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-padding-[headline]->=0-[byline]-padding-|" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
    //
    //    // Image and button vertical layout - spacing at least 15 between the two
    //    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-padding-[imageView]->=padding-[button]-padding-|" options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight metrics:metrics views:views]];
    
}
@end
