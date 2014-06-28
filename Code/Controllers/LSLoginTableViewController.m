//
//  LSLoginTableViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import "LSLoginTableViewController.h"
#import "LSInputTableViewCell.h"
#import "LSConversationListViewController.h"
#import "LSButton.h"
#import "LSUserManager.h"

@interface LSLoginTableViewController () <UITextFieldDelegate>

@property (nonatomic, strong) LSButton *loginButton;
@property (nonatomic, weak) UITextField *emailField;
@property (nonatomic, weak) UITextField *passwordField;
@property (nonatomic, copy) void (^completionBlock)(LSUser *);
@end

@implementation LSLoginTableViewController

static NSString *const LSLoginlIdentifier = @"loginCellIdentifier";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Login";
    self.accessibilityLabel = @"Login Screen";
    
    [self initializeLoginButton];
    [self configureLayoutConstraints];
    [self.tableView registerClass:[LSInputTableViewCell class] forCellReuseIdentifier:LSLoginlIdentifier];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.emailField becomeFirstResponder];
}

- (void)initializeLoginButton
{
    self.LoginButton = [[LSButton alloc] initWithText:@"Login"];
    [self.loginButton addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
    self.loginButton.enabled = NO;
    [self.view addSubview:self.loginButton];
}

- (void)configureLayoutConstraints
{
    self.loginButton.frame = CGRectMake(0, 0, 280, 60);
    self.loginButton.center = CGPointMake(self.view.center.x, 220);
}

#pragma mark 
#pragma mark TableView Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LSInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LSLoginlIdentifier forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(LSInputTableViewCell *)cell forIndexPath:(NSIndexPath *)path
{
    switch (path.row) {
        case 0:
            [cell setText:@"Email"];
            cell.textField.accessibilityLabel = @"Email";
            cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
            cell.textField.enablesReturnKeyAutomatically = YES;
            cell.textField.returnKeyType = UIReturnKeyNext;
            cell.textField.delegate = self;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            self.emailField = cell.textField;
            break;
        case 1:
            [cell setText:@"Password"];
            cell.textField.accessibilityLabel = @"Password";
            cell.textField.secureTextEntry = YES;
            cell.textField.returnKeyType = UIReturnKeySend;
            cell.textField.delegate = self;
            self.passwordField = cell.textField;
            break;
        default:
            break;
    }
}

- (void)loginTapped
{
    LSInputTableViewCell *usernameCell = (LSInputTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    LSInputTableViewCell *passwordCell = (LSInputTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    [SVProgressHUD show];
    [self.authenticationManager loginWithEmail:usernameCell.textField.text password:passwordCell.textField.text completion:^(LSUser *user, NSError *error) {
        [SVProgressHUD dismiss];
        if (user) {
            if (self.completionBlock) self.completionBlock(user);
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField == self.passwordField) {
        [self loginTapped];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.loginButton.enabled = (self.emailField.text.length && self.passwordField.text.length);
    return YES;
}

@end

