//
//  LSTableViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSAuthenticationTableViewController.h"
#import "LSInputTableViewCell.h"
#import "LSAuthenticationTableViewHeader.h"
#import "LSAuthenticationTableViewFooter.h"
#import "LYRUIConstants.h"
#import "SVProgressHUD.h"
#import "LSUtilities.h"

typedef NS_ENUM(NSInteger, LSLoginRow) {
    LSLoginRowEmail,
    LSLoginRowPassword,
    LSLoginRowCount,
};

typedef NS_ENUM(NSInteger, LSRegisterRow) {
    LSRegisterRowFirstName,
    LSRegisterRowLastName,
    LSRegisterRowEmail,
    LSRegisterRowPassword,
    LSRegisterRowConfirmation,
    LSRegisterRowCount,
};

@interface LSAuthenticationTableViewController () <LSAuthenticationTableViewFooterDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *confirmation;

@property (nonatomic, weak) UITextField *firstNameTextField;
@property (nonatomic, weak) UITextField *lastNameTextField;
@property (nonatomic, weak) UITextField *emailTextField;
@property (nonatomic, weak) UITextField *passwordTextField;
@property (nonatomic, weak) UITextField *confirmationTextField;

@property (nonatomic) LSAuthenticationState authenticationState;
@property (nonatomic, weak) LSAuthenticationTableViewHeader *tableViewHeader;

@end

@implementation LSAuthenticationTableViewController

static NSString *const LSAuthenticationCellIdentifier = @"authenticationCellIdentifier";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _authenticationState = LSAuthenticationStateLogin;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.rowHeight = 44;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.tableView registerClass:[LSInputTableViewCell class] forCellReuseIdentifier:LSAuthenticationCellIdentifier];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (self.isEditing == editing) return;

    [super setEditing:editing animated:animated];

    // We need to trigger the recalculation of the table view's height (i.e. namely the header since its height is different when editing) so we call the following without actually making any table view updates.
    if (animated) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    } else {
        [UIView performWithoutAnimation:^{
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        }];
    }

    self.tableViewHeader.showsContent = !editing;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.authenticationState) {
        case LSAuthenticationStateRegister:
            return LSRegisterRowCount;
            
        case LSAuthenticationStateLogin:
            return LSLoginRowCount;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LSInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LSAuthenticationCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Cell Configuration

- (void)configureCell:(LSInputTableViewCell *)cell forIndexPath:(NSIndexPath *)path
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
        case LSAuthenticationStateLogin:
            switch ((LSLoginRow)path.row) {
                case LSLoginRowEmail:
                    [self configureEmailCell:cell];
                    break;
                    
                case LSLoginRowPassword:
                    [self configurePasswordCell:cell];
                    cell.textField.returnKeyType = UIReturnKeySend;
                    break;
                    
                case LSLoginRowCount:
                    break;
            }
            break;
            
        case LSAuthenticationStateRegister:
            switch ((LSRegisterRow)path.row) {
                case LSRegisterRowFirstName:
                    [self configureFirstNameCell:cell];
                    break;
                    
                case LSRegisterRowLastName:
                    [self configureLastNameCell:cell];
                    break;
                    
                case LSRegisterRowEmail:
                    [self configureEmailCell:cell];
                    break;

                case LSRegisterRowPassword:
                    [self configurePasswordCell:cell];
                    break;

                case LSRegisterRowConfirmation:
                    [self configureConfirmationCell:cell];
                    break;
                    
                case LSRegisterRowCount:
                    break;
            }
            break;
    }
}

- (void)configureEmailCell:(LSInputTableViewCell *)cell
{
    [cell setGuideText:@"Email:"];
    [cell setPlaceHolderText:@"Enter Your Email"];
    cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
    cell.textField.text = self.email;
    self.emailTextField = cell.textField;
}

- (void)configurePasswordCell:(LSInputTableViewCell *)cell
{
    [cell setGuideText:@"Password:"];
    [cell setPlaceHolderText:@"Enter Your Password"];
    cell.textField.secureTextEntry = YES;
    cell.textField.text = self.password;
    self.passwordTextField = cell.textField;
}

- (void)configureFirstNameCell:(LSInputTableViewCell *)cell
{
    [cell setGuideText:@"First Name:"];
    [cell setPlaceHolderText:@"Enter Your First Name"];
    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    cell.textField.text = self.firstName;
    self.firstNameTextField = cell.textField;
}

- (void)configureLastNameCell:(LSInputTableViewCell *)cell
{
    [cell setGuideText:@"Last Name:"];
    [cell setPlaceHolderText:@"Enter Your Last Name"];
    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    cell.textField.text = self.lastName;
    self.lastNameTextField = cell.textField;
}

- (void)configureConfirmationCell:(LSInputTableViewCell *)cell
{
    [cell setGuideText:@"Confirmation:"];
    [cell setPlaceHolderText:@"Confirm It Please"];
    cell.textField.secureTextEntry = YES;
    cell.textField.returnKeyType = UIReturnKeySend;
    cell.textField.text = self.confirmation;
    self.confirmationTextField = cell.textField;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (self.authenticationState) {
        case LSAuthenticationStateLogin:
            if (self.isEditing) {
                return 60;
            } else {
                return 200;
            }

        case LSAuthenticationStateRegister:
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
    LSAuthenticationTableViewHeader *header = [LSAuthenticationTableViewHeader new];
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
    LSAuthenticationTableViewFooter *footer = [LSAuthenticationTableViewFooter new];
    footer.authenticationState = self.authenticationState;
    footer.delegate = self;
    return footer;
}

#pragma mark - LSAuthenticationTableViewFooterDelegate

- (void)authenticationTableViewFooter:(LSAuthenticationTableViewFooter *)tableViewFooter primaryActionButtonTappedWithAuthenticationState:(LSAuthenticationState)authenticationState
{
    switch (authenticationState) {
        case LSAuthenticationStateLogin:
            if (self.isEditing) {
                [self attemptLogin];
            } else {
                [self setEditing:YES animated:YES];
                [self.emailTextField becomeFirstResponder];
            }
            break;
            
        case LSAuthenticationStateRegister:
            if (self.isEditing) {
                [self attemptRegistration];
            } else {
                [self setEditing:YES animated:YES];
                [self.firstNameTextField becomeFirstResponder];
            }
            break;
    }
}

- (void)authenticationTableViewFooter:(LSAuthenticationTableViewFooter *)tableViewFooter secondaryActionButtonTappedWithAuthenticationState:(LSAuthenticationState)authenticationState
{
    self.authenticationState = authenticationState;
    [self configureTableViewForAuthenticationState:authenticationState];
}

- (void)environmentButtonTappedForAuthenticationTableViewFooter:(LSAuthenticationTableViewFooter *)tableViewFooter
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Production - Prod", @"Production - Sandbox", @"Staging", @"Dev-1", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self.delegate authenticationTableViewController:self didSelectEnvironment:LYRUIProduction];
            break;
            
        case 1:
            [self.delegate authenticationTableViewController:self didSelectEnvironment:LYRUIDevelopment];
            break;
            
        case 2:
            [self.delegate authenticationTableViewController:self didSelectEnvironment:LYRUIStage1];
            break;
        
        case 3:
            [self.delegate authenticationTableViewController:self didSelectEnvironment:LYRUIDev1];
            break;

        default:
            break;
    }
}

#pragma mark - State Configuration

- (void)configureTableViewForAuthenticationState:(LSAuthenticationState)authenticationState
{
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:LSRegisterRowFirstName inSection:0],
                            [NSIndexPath indexPathForRow:LSRegisterRowLastName inSection:0],
                            [NSIndexPath indexPathForRow:LSRegisterRowConfirmation inSection:0]];

    [self.tableView beginUpdates];
    switch (authenticationState) {
        case LSAuthenticationStateLogin:
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case LSAuthenticationStateRegister:
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
    [self.tableView endUpdates];

    // Cells that aren't being inserted or deleted may display different content depending on the state so they must be reconfigured.
    for (LSInputTableViewCell *cell in [self.tableView visibleCells]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        switch (authenticationState) {
            case LSAuthenticationStateLogin:
                break;

            case LSAuthenticationStateRegister:
                if ([indexPaths containsObject:indexPath]) continue;
                break;
        }
        [self configureCell:cell forIndexPath:indexPath];
    }

    if (self.isEditing) {
        switch (authenticationState) {
            case LSAuthenticationStateLogin:
                [self.emailTextField becomeFirstResponder];
                break;

            case LSAuthenticationStateRegister:
                [self.firstNameTextField becomeFirstResponder];
                break;
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch (self.authenticationState) {
        case LSAuthenticationStateLogin:
            if (textField == self.emailTextField) {
                [self.passwordTextField becomeFirstResponder];
            } else if (textField == self.passwordTextField) {
                [self attemptLogin];
            }
            break;
            
        case LSAuthenticationStateRegister:
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
            LSAlertWithError(error);
            [SVProgressHUD dismiss];
            return;
        }
        NSLog(@"Nonce Created");
        [SVProgressHUD setStatus:@"Requesting Identity Token"];
        [self.applicationController.APIManager authenticateWithEmail:email password:password nonce:nonce completion:^(NSString *identityToken, NSError *error) {
            if (error) {
                LSAlertWithError(error);
                [SVProgressHUD dismiss];
                return;
            }
            NSLog(@"Identity Token Created");
            [SVProgressHUD setStatus:@"Authenticating With Layer"];
            [self.applicationController.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                if (error) {
                    LSAlertWithError(error);
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
    LSUser *user = [LSUser new];
    user.firstName = self.firstName;
    user.lastName = self.lastName;
    user.email = self.email;
    user.password = self.password;
    user.passwordConfirmation = self.confirmation;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [self.view endEditing:YES];
    [self.applicationController.APIManager registerUser:user completion:^(LSUser *user, NSError *error) {
        if (error) {
            LSAlertWithError(error);
            [SVProgressHUD dismiss];
            return;
        }
        [self.applicationController.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
            if (error) {
                LSAlertWithError(error);
                [SVProgressHUD dismiss];
                return;
            }
            [self.applicationController.APIManager authenticateWithEmail:user.email password:user.password nonce:nonce completion:^(NSString *identityToken, NSError *error) {
                if (error) {
                    LSAlertWithError(error);
                    [SVProgressHUD dismiss];
                    return;
                }
                [self.applicationController.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                    if (error) {
                        LSAlertWithError(error);
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
    self.authenticationState = LSAuthenticationStateLogin;
    [self.tableView reloadData];
    [self setEditing:NO animated:YES];
}

@end
