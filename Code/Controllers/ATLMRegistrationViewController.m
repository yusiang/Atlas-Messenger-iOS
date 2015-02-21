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
#import "ATLMUtilities.h"

@interface ATLMRegistrationViewController () <UITextFieldDelegate>

@property (nonatomic) ATLLogoView *logoView;
@property (nonatomic) UITextField *registrationTextField;
@property (nonatomic) NSLayoutConstraint *registrationTextFieldBottomConstraint;

@end

@implementation ATLMRegistrationViewController

CGFloat const ATLMLogoViewBCenterYOffset = 160;
CGFloat const ATLMregistrationTextFieldWidthRatio = 0.8;
CGFloat const ATLMregistrationTextFieldHeight = 60;
CGFloat const ATLMregistrationTextFieldBottomPadding = 20;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.logoView = [[ATLLogoView alloc] init];
    self.logoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.logoView];
    
    self.registrationTextField = [[UITextField alloc] init];
    self.registrationTextField .translatesAutoresizingMaskIntoConstraints = NO;
    self.registrationTextField .delegate = self;
    self.registrationTextField .placeholder = @"My name is...";
    self.registrationTextField .textAlignment = NSTextAlignmentCenter;
    self.registrationTextField .layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.registrationTextField .layer.borderWidth = 0.5;
    self.registrationTextField .layer.cornerRadius = 2;
    self.registrationTextField.font = [UIFont systemFontOfSize:22];
    self.registrationTextField .returnKeyType = UIReturnKeyGo;
    [self.view addSubview:self.registrationTextField ];
    
    [self configureLayoutConstraints];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.registrationTextField becomeFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.registrationTextFieldBottomConstraint.constant = -rect.size.height - ATLMregistrationTextFieldBottomPadding;
    
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
            ATLMAlertWithError(error);
            return;
        }
        NSLog(@"Registering user");
        [self.applicationController.APIManager registerUserWithName:name nonce:nonce completion:^(NSString *identityToken, NSError *error) {
            NSLog(@"User registerd and got identity token: %@", identityToken);
            if (error) {
                ATLMAlertWithError(error);
                return;
            }
            NSLog(@"Authenticating Layer");
            [self.applicationController.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                NSLog(@"Layer authenticated as: %@", authenticatedUserID);
                if (error) {
                    ATLMAlertWithError(error);
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
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.registrationTextField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.registrationTextField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:ATLMregistrationTextFieldWidthRatio constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.registrationTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ATLMregistrationTextFieldHeight]];
    self.registrationTextFieldBottomConstraint = [NSLayoutConstraint constraintWithItem:self.registrationTextField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ATLMregistrationTextFieldBottomPadding];
    [self.view addConstraint:self.registrationTextFieldBottomConstraint];
}

@end
