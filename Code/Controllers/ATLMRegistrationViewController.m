//
//  LSRegistrationViewController.m
//  QRCodeTest
//
//  Created by Kevin Coleman on 2/15/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import "ATLMRegistrationViewController.h"
#import "ATLLogoView.h"
#import <Atlas/Atlas.h> 
#import "ATLMLayerClient.h"
#import "ATLMAPIManager.h"
#import "ATLMConstants.h"

@interface ATLMRegistrationViewController () <UITextFieldDelegate>

@property (nonatomic) ATLLogoView *logoView;
@property (nonatomic) UITextField *registrationField;
@property (nonatomic) NSLayoutConstraint *registrationFieldBottomConstraint;

@end

@implementation ATLMRegistrationViewController

CGFloat const ATLMLogoViewBCenterYOffset = 160;
CGFloat const ATLMRegistrationFieldWidthRatio = 0.8;
CGFloat const ATLMRegistrationFieldHeight = 60;
CGFloat const ATLMRegistrationFieldBottomPadding = 20;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.logoView = [[ATLLogoView alloc] init];
    self.logoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.logoView];
    
    self.registrationField = [[UITextField alloc] init];
    self.registrationField .translatesAutoresizingMaskIntoConstraints = NO;
    self.registrationField .delegate = self;
    self.registrationField .placeholder = @"My name is...";
    self.registrationField .textAlignment = NSTextAlignmentCenter;
    self.registrationField .layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.registrationField .layer.borderWidth = 0.5;
    self.registrationField .layer.cornerRadius = 2;
    self.registrationField.font = [UIFont systemFontOfSize:22];
    self.registrationField .returnKeyType = UIReturnKeyGo;
    [self.view addSubview:self.registrationField ];
    
    [self configureLayoutConstraints];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.registrationField becomeFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.registrationFieldBottomConstraint.constant = -rect.size.height - ATLMRegistrationFieldBottomPadding;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
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
    // Logo View
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logoView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logoView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-ATLMLogoViewBCenterYOffset]];
    
    // Registration View
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.registrationField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.registrationField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:ATLMRegistrationFieldWidthRatio constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.registrationField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ATLMRegistrationFieldHeight]];
    self.registrationFieldBottomConstraint = [NSLayoutConstraint constraintWithItem:self.registrationField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ATLMRegistrationFieldBottomPadding];
    [self.view addConstraint:self.registrationFieldBottomConstraint];
}

@end
