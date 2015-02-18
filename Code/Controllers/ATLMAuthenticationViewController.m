//
//  ATLMAuthenticationViewController.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ATLMAuthenticationViewController.h"
#import "ATLMInputTableViewCell.h"
#import "ATLMAuthenticationTableViewHeader.h"
#import "ATLMAuthenticationTableViewFooter.h"
#import "SVProgressHUD.h"
#import "ATLMUtilities.h"
#import "ATLMErrors.h"

typedef NS_ENUM(NSInteger, ATLMLoginRow) {
    ATLMLoginRowEmail,
    ATLMLoginRowPassword,
    ATLMLoginRowCount,
};

typedef NS_ENUM(NSInteger, ATLMRegisterRow) {
    ATLMRegisterRowFirstName,
    ATLMRegisterRowLastName,
    ATLMRegisterRowEmail,
    ATLMRegisterRowPassword,
    ATLMRegisterRowConfirmation,
    ATLMRegisterRowCount,
};

@interface ATLMAuthenticationViewController () <UITableViewDataSource, UITableViewDelegate, ATLMAuthenticationTableViewFooterDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *confirmation;

@property (nonatomic) UITableView *tableView;
@property (nonatomic, weak) UITextField *firstNameTextField;
@property (nonatomic, weak) UITextField *lastNameTextField;
@property (nonatomic, weak) UITextField *emailTextField;
@property (nonatomic, weak) UITextField *passwordTextField;
@property (nonatomic, weak) UITextField *confirmationTextField;

@property (nonatomic) ATLMAuthenticationState authenticationState;
@property (nonatomic, weak) ATLMAuthenticationTableViewHeader *tableViewHeader;

@end

@implementation ATLMAuthenticationViewController

static NSString *const ATLMAuthenticationCellIdentifier = @"authenticationCellIdentifier";

NSString *const ATLMFirstNameRowPlaceholderText = @"Enter Your First Name";
NSString *const ATLMLastNameRowPlaceholderText = @"Enter Your Last Name";
NSString *const ATLMEmailRowPlaceholderText = @"Enter Your Email";
NSString *const ATLMPasswordRowPlaceholderText = @"Enter Your Password";
NSString *const ATLMConfirmationRowPlaceholderText = @"Confirm Your Password";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _authenticationState = ATLMAuthenticationStateLogin;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // We're not using UITableViewController because its handling of the keyboard causes the table view to scroll multiple times unnecessarily and can leave our text fields offscreen on a 3.5-inch device.
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 44;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.tableView registerClass:[ATLMInputTableViewCell class] forCellReuseIdentifier:ATLMAuthenticationCellIdentifier];
    [self.view addSubview:self.tableView];

    [self configureLayoutConstraintsForTableView];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (self.isEditing == editing) return;

    [super setEditing:editing animated:animated];

    // We need to trigger the recalculation of the table view's height (i.e. namely the header since its height is different when editing) so we call the following without actually making any table view updates.
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.tableView beginUpdates];
            [self.tableView endUpdates];

            // We make this call within our own animation block to have the section header's content/constraints animate alongside the table view animations.
            [self.tableView layoutIfNeeded];

            self.tableViewHeader.showsContent = !editing;
        }];
    } else {
        [UIView performWithoutAnimation:^{
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        }];
        self.tableViewHeader.showsContent = !editing;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.authenticationState) {
        case ATLMAuthenticationStateRegister:
            return ATLMRegisterRowCount;
            
        case ATLMAuthenticationStateLogin:
            return ATLMLoginRowCount;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ATLMInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ATLMAuthenticationCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Cell Configuration

- (void)configureCell:(ATLMInputTableViewCell *)cell forIndexPath:(NSIndexPath *)path
{
    cell.textField.text = nil;
    cell.textField.delegate = self;
    cell.textField.keyboardType = UIKeyboardTypeDefault;
    cell.textField.returnKeyType = UIReturnKeyNext;
    cell.textField.enablesReturnKeyAutomatically = YES;
    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    cell.textField.secureTextEntry = NO;
    [cell.textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];

    switch (self.authenticationState) {
        case ATLMAuthenticationStateLogin:
            switch ((ATLMLoginRow)path.row) {
                case ATLMLoginRowEmail:
                    [self configureEmailCell:cell];
                    break;
                    
                case ATLMLoginRowPassword:
                    [self configurePasswordCell:cell];
                    cell.textField.returnKeyType = UIReturnKeySend;
                    break;
                    
                case ATLMLoginRowCount:
                    break;
            }
            break;
            
        case ATLMAuthenticationStateRegister:
            switch ((ATLMRegisterRow)path.row) {
                case ATLMRegisterRowFirstName:
                    [self configureFirstNameCell:cell];
                    break;
                    
                case ATLMRegisterRowLastName:
                    [self configureLastNameCell:cell];
                    break;
                    
                case ATLMRegisterRowEmail:
                    [self configureEmailCell:cell];
                    break;

                case ATLMRegisterRowPassword:
                    [self configurePasswordCell:cell];
                    break;

                case ATLMRegisterRowConfirmation:
                    [self configureConfirmationCell:cell];
                    break;
                    
                case ATLMRegisterRowCount:
                    break;
            }
            break;
    }
}

- (void)configureEmailCell:(ATLMInputTableViewCell *)cell
{
    [cell setGuideText:@"Email:"];
    [cell setPlaceHolderText:ATLMEmailRowPlaceholderText];
    cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
    cell.textField.text = self.email;
    self.emailTextField = cell.textField;
}

- (void)configurePasswordCell:(ATLMInputTableViewCell *)cell
{
    [cell setGuideText:@"Password:"];
    [cell setPlaceHolderText:ATLMPasswordRowPlaceholderText];
    cell.textField.secureTextEntry = YES;
    cell.textField.text = self.password;
    self.passwordTextField = cell.textField;
}

- (void)configureFirstNameCell:(ATLMInputTableViewCell *)cell
{
    [cell setGuideText:@"First Name:"];
    [cell setPlaceHolderText:ATLMFirstNameRowPlaceholderText];
    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    cell.textField.text = self.firstName;
    self.firstNameTextField = cell.textField;
}

- (void)configureLastNameCell:(ATLMInputTableViewCell *)cell
{
    [cell setGuideText:@"Last Name:"];
    [cell setPlaceHolderText:ATLMLastNameRowPlaceholderText];
    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    cell.textField.text = self.lastName;
    self.lastNameTextField = cell.textField;
}

- (void)configureConfirmationCell:(ATLMInputTableViewCell *)cell
{
    [cell setGuideText:@"Confirmation:"];
    [cell setPlaceHolderText:ATLMConfirmationRowPlaceholderText];
    cell.textField.secureTextEntry = YES;
    cell.textField.returnKeyType = UIReturnKeySend;
    cell.textField.text = self.confirmation;
    self.confirmationTextField = cell.textField;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (self.authenticationState) {
        case ATLMAuthenticationStateLogin:
            if (self.isEditing) {
                return 60;
            } else {
                return 200;
            }

        case ATLMAuthenticationStateRegister:
            if (self.isEditing) {
                return 20;
            } else {
                return 140;
            }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 240;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ATLMAuthenticationTableViewHeader *header = [ATLMAuthenticationTableViewHeader new];
    self.tableViewHeader = header;
    if (self.isEditing) {
        header.showsContent = NO;
    } else {
        header.showsContent = YES;
    }
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    ATLMAuthenticationTableViewFooter *footer = [ATLMAuthenticationTableViewFooter new];
    footer.authenticationState = self.authenticationState;
    footer.delegate = self;
    return footer;
}

#pragma mark - LSAuthenticationTableViewFooterDelegate

- (void)authenticationTableViewFooter:(ATLMAuthenticationTableViewFooter *)tableViewFooter primaryActionButtonTappedWithAuthenticationState:(ATLMAuthenticationState)authenticationState
{
    switch (authenticationState) {
        case ATLMAuthenticationStateLogin:
            if (self.isEditing) {
                [self attemptLogin];
            } else {
                [self setEditing:YES animated:YES];
                [self.emailTextField becomeFirstResponder];
            }
            break;
            
        case ATLMAuthenticationStateRegister:
            if (self.isEditing) {
                [self attemptRegistration];
            } else {
                [self setEditing:YES animated:YES];
                [self.firstNameTextField becomeFirstResponder];
            }
            break;
    }
}

- (void)authenticationTableViewFooter:(ATLMAuthenticationTableViewFooter *)tableViewFooter secondaryActionButtonTappedWithAuthenticationState:(ATLMAuthenticationState)authenticationState
{
    self.authenticationState = authenticationState;
    [self configureTableViewForAuthenticationState:authenticationState];
}

- (void)environmentButtonTappedForAuthenticationTableViewFooter:(ATLMAuthenticationTableViewFooter *)tableViewFooter
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Production - Prod APNs", @"Production - Dev APNs", @"Staging - Prod APNs", @"Staging - Dev APNs", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self.delegate authenticationViewController:self didSelectEnvironment:ATLMProductionEnvironment];
            break;
            
        case 1:
            [self.delegate authenticationViewController:self didSelectEnvironment:ATLMProductionDebugEnvironment];
            break;
            
        case 2:
            [self.delegate authenticationViewController:self didSelectEnvironment:ATLMStagingEnvironment];
            break;
            
        case 3:
            [self.delegate authenticationViewController:self didSelectEnvironment:ATLMStagingDebugEnvironment];
            break;

        default:
            break;
    }
}

#pragma mark - State Configuration

- (void)configureTableViewForAuthenticationState:(ATLMAuthenticationState)authenticationState
{
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:ATLMRegisterRowFirstName inSection:0],
                            [NSIndexPath indexPathForRow:ATLMRegisterRowLastName inSection:0],
                            [NSIndexPath indexPathForRow:ATLMRegisterRowConfirmation inSection:0]];

    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView beginUpdates];
        switch (authenticationState) {
            case ATLMAuthenticationStateLogin:
                // We use the fade animation here for consistency with the insertion animation below.
                [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                break;

            case ATLMAuthenticationStateRegister:
                // We use the fade animation here instead of automatic since automatic causes the inserted cells to immediately appear instead of animating on iOS 8.
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
        [self.tableView endUpdates];

        // We make this call within our own animation block to have the section header's content/constraints animate alongside the table view animations.
        [self.tableView layoutIfNeeded];
    }];

    // Cells that aren't being inserted or deleted may display different content depending on the state so they must be reconfigured.
    for (ATLMInputTableViewCell *cell in [self.tableView visibleCells]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        switch (authenticationState) {
            case ATLMAuthenticationStateLogin:
                break;

            case ATLMAuthenticationStateRegister:
                if ([indexPaths containsObject:indexPath]) continue;
                break;
        }
        [self configureCell:cell forIndexPath:indexPath];
    }

    if (self.isEditing) {
        switch (authenticationState) {
            case ATLMAuthenticationStateLogin:
                [self.emailTextField becomeFirstResponder];
                break;

            case ATLMAuthenticationStateRegister:
                [self.firstNameTextField becomeFirstResponder];
                break;
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch (self.authenticationState) {
        case ATLMAuthenticationStateLogin:
            if (textField == self.emailTextField) {
                [self.passwordTextField becomeFirstResponder];
            } else if (textField == self.passwordTextField) {
                [self attemptLogin];
            }
            break;
            
        case ATLMAuthenticationStateRegister:
            if (textField == self.firstNameTextField) {
                [self.lastNameTextField becomeFirstResponder];
            } else if (textField == self.lastNameTextField) {
                [self.emailTextField becomeFirstResponder];
            } else if (textField == self.emailTextField) {
                [self.passwordTextField becomeFirstResponder];
            } else if (textField == self.passwordTextField) {
                [self.confirmationTextField becomeFirstResponder];
            } else if (textField == self.confirmationTextField) {
                [self attemptRegistration];
            }
            break;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self setEditing:YES animated:YES];
    return YES;
}

#pragma mark - Layout Constraints

- (void)configureLayoutConstraintsForTableView
{
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
}

#pragma mark - Actions

- (void)textFieldEditingChanged:(UITextField *)textField
{
    if (textField == self.firstNameTextField) {
        self.firstName = textField.text;
    } else if (textField == self.lastNameTextField) {
        self.lastName = textField.text;
    } else if (textField == self.emailTextField) {
        self.email = textField.text;
    } else if (textField == self.passwordTextField) {
        self.password = textField.text;
    } else if (textField == self.confirmationTextField) {
        self.confirmation = textField.text;
    }
}

#pragma mark - Logging In

- (void)attemptLogin
{
    NSString *email = self.email;
    NSString *password = self.password;
    
    [SVProgressHUD showWithStatus:@"Requesting Nonce" maskType:SVProgressHUDMaskTypeBlack];
    [self.view endEditing:YES];
    [self.applicationController.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        if (error) {
            ATLMAlertWithError(error);
            [SVProgressHUD dismiss];
            return;
        }
        NSLog(@"Nonce Created");
        [SVProgressHUD setStatus:@"Requesting Identity Token"];
        [self.applicationController.APIManager authenticateWithEmail:email password:password nonce:nonce completion:^(NSString *identityToken, NSError *error) {
            if (error) {
                ATLMAlertWithError(error);
                [SVProgressHUD dismiss];
                return;
            }
            NSLog(@"Identity Token Created");
            [SVProgressHUD setStatus:@"Authenticating With Layer"];
            [self.applicationController.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                if (error) {
                    ATLMAlertWithError(error);
                    [SVProgressHUD dismiss];
                    return;
                }
                NSLog(@"User Authenticated");
                [SVProgressHUD dismiss];
            }];
        }];
    }];
}

#pragma mark - Registration

- (void)attemptRegistration
{
    ATLMUser *user = [ATLMUser new];
    user.firstName = self.firstName;
    user.lastName = self.lastName;
    user.email = self.email;
    user.password = self.password;
    user.passwordConfirmation = self.confirmation;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [self.view endEditing:YES];
    [self.applicationController.APIManager registerUser:user completion:^(ATLMUser *user, NSError *error) {
        if (error) {
            ATLMAlertWithError(error);
            [SVProgressHUD dismiss];
            return;
        }
        [self.applicationController.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
            if (error) {
                ATLMAlertWithError(error);
                [SVProgressHUD dismiss];
                return;
            }
            [self.applicationController.APIManager authenticateWithEmail:user.email password:user.password nonce:nonce completion:^(NSString *identityToken, NSError *error) {
                if (error) {
                    ATLMAlertWithError(error);
                    [SVProgressHUD dismiss];
                    return;
                }
                [self.applicationController.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                    if (error) {
                        ATLMAlertWithError(error);
                        [SVProgressHUD dismiss];
                        return;
                    }
                    [SVProgressHUD dismiss];
                }];
            }];
        }];
    }];
}

#pragma mark - Resetting

- (void)resetState
{
    self.firstName = nil;
    self.lastName = nil;
    self.email = nil;
    self.password = nil;
    self.confirmation = nil;
    
    self.firstNameTextField = nil;
    self.lastNameTextField = nil;
    self.emailTextField = nil;
    self.passwordTextField = nil;
    self.confirmationTextField = nil;
    
    self.authenticationState = ATLMAuthenticationStateLogin;
    [self.tableView reloadData];
    [self setEditing:NO animated:YES];
}

@end
