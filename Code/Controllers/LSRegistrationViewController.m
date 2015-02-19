//
//  LSRegistrationViewController.m
//  QRCodeTest
//
//  Created by Kevin Coleman on 2/15/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import "LSRegistrationViewController.h"
#import "ATLLogoView.h"
#import <Atlas/Atlas.h> 
#import "ATLMLayerClient.h"
#import "ATLMAPIManager.h"
//#import "LYRIdentityManager.h"

@interface LSRegistrationViewController () <UITextFieldDelegate>

@property (nonatomic) ATLLogoView *logoView;
@property (nonatomic) UITextField *registrationFeild;

@end

@implementation LSRegistrationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.logoView = [[ATLLogoView alloc] init];
    self.logoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.logoView];
    
    self.registrationFeild = [[UITextField alloc] init];
    self.registrationFeild.translatesAutoresizingMaskIntoConstraints = NO;
    self.registrationFeild.delegate = self;
    self.registrationFeild.placeholder = @"My Name Is...";
    self.registrationFeild.textAlignment = NSTextAlignmentCenter;
    self.registrationFeild.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.registrationFeild.layer.borderWidth = 0.5;
    self.registrationFeild.layer.cornerRadius = 2;
    self.registrationFeild.returnKeyType = UIReturnKeyGo;
    [self.view addSubview:self.registrationFeild];
    
    [self configureLayoutConstraints];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.registrationFeild becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self registerAndAuthenticateUserWithName:textField.text];
    return YES;
}

- (void)registerAndAuthenticateUserWithName:(NSString *)name
{
    [self.view endEditing:YES];

    if (self.applicationController.layerClient.authenticatedUserID) {
        NSLog(@"Layer already authenticated as: %@", self.applicationController.layerClient.authenticatedUserID);
        return;
    }
    
    NSLog(@"Requesting Authentication Nonce");
    [self.applicationController.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        NSLog(@"Got a nonce %@", nonce);
        if (error) {
            NSLog(@"Authenticate Nonce Request failed with error:%@", error);
            return;
        }
        NSLog(@"Registering user");
        [self.applicationController.APIManager registerUserWithName:name nonce:nonce completion:^(NSString *identityToken, NSError *error) {
            NSLog(@"User registerd and got identity token: %@", identityToken);
            if (error) {
                NSLog(@"Failed to register user with error:%@", error);
                return;
            }
            NSLog(@"Authenticating Layer");
            [self.applicationController.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                NSLog(@"Layer authenticated as: %@", authenticatedUserID);
                if (error) {
                    NSLog(@"Failed authenticating layer client with error: %@", error);
                    return;
                }
            }];
        }];
    }];
}

- (void)configureLayoutConstraints
{
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logoView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:60]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.registrationFeild attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.registrationFeild attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:260]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.registrationFeild attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:280]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.registrationFeild attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:52]];
}

@end
