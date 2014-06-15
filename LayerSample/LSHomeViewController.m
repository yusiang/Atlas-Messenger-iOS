//
//  LSHomeViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSHomeViewController.h"
#import "LSNavigationController.h"
#import "LSButton.h"

@interface LSHomeViewController ()

@end

@implementation LSHomeViewController

#define kLayerColor     [UIColor colorWithRed:36.0f/255.0f green:166.0f/255.0f blue:225.0f/255.0f alpha:1.0]
#define kLayerFont      @"Avenir-Medium"

- (id)init
{
    self = [super init];
    if (self) {
        [self.view setBackgroundColor:[UIColor whiteColor]];
         self.title = @"Home";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addTitleText];
    [self addRegistrationButton];
    [self addLoginButton];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addTitleText
{
    UILabel *layerLabel = [[UILabel alloc] init];
    layerLabel.text = @"Layer Chat";
    layerLabel.font = [UIFont fontWithName:kLayerFont size:42];
    layerLabel.textColor = kLayerColor;
    [layerLabel sizeToFit];
    layerLabel.center = self.view.center;
    layerLabel.center = CGPointMake(layerLabel.center.x, layerLabel.center.y - 100);
    [self.view addSubview:layerLabel];
}

- (void)addRegistrationButton
{
    LSButton *registrationButton = [self buttonWithText:@"Register"];
    [registrationButton setCenterY:380];
    [registrationButton setBackgroundColor:kLayerColor];
    [registrationButton addTarget:self action:@selector(registerTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registrationButton];
}

- (void)registerTapped
{
    LSRegistrationTableViewController *registerVC = [[LSRegistrationTableViewController alloc] init];
    registerVC.delegate = self;
    [self.navigationController pushViewController:registerVC animated:TRUE];
}

- (void)addLoginButton
{
    LSButton *loginButton = [self buttonWithText:@"Login"];
    [loginButton setCenterY:460];
    [loginButton setBorderColor:kLayerColor];
    [loginButton setTextColor:kLayerColor];
    [loginButton addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
}

- (void)loginTapped
{
    LSLoginTableViewController *loginVC = [[LSLoginTableViewController alloc] init];
    loginVC.delegate = self;
    [self.navigationController pushViewController:loginVC animated:TRUE];
}

- (LSButton *)buttonWithText:(NSString *)text
{
    CGRect rect = CGRectMake(0, 0, 280, 60);
    LSButton *button = [[LSButton alloc] initWithFrame:rect];
    [button setText:text];
    [button setFont:[UIFont fontWithName:kLayerFont size:20]];
    [button.layer setCornerRadius:4.0f];
    button.center = self.view.center;
    return button;
}

#pragma mark
#pragma mark LSRegistrationViewControllerDelegate Methods

-(void)registrationSuccessful
{
    [self.delegate presentConversationViewController];
}

#pragma mark
#pragma mark LSLoginViewControllerDelegate Methods

-(void)loginSuccess
{
    [self.delegate presentConversationViewController];
}

@end
