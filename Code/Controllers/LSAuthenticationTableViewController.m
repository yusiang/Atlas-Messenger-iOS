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

@interface LSAuthenticationTableViewController () <LSAuthenticationTableViewFooterDelegate, UITextFieldDelegate, UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic) UITextField *firstName;
@property (nonatomic) UITextField *lastName;
@property (nonatomic) UITextField *email;
@property (nonatomic) UITextField *password;
@property (nonatomic) UITextField *confirmation;

@property (nonatomic) LSAuthenticationState authenticationState;
@property (nonatomic) LSAuthenticationTableViewHeader *tableViewHeader;

@end

@implementation LSAuthenticationTableViewController

static NSString *const LSAuthenticationCellIdentifier = @"authenticationCellIdentifier";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.authenticationState = LSAuthenticationStateLogin;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.tableView registerClass:[LSInputTableViewCell class] forCellReuseIdentifier:LSAuthenticationCellIdentifier];
    [self.tableView setContentOffset:CGPointMake(0, 140)];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.authenticationState) {
        case LSAuthenticationStateRegister:
            return 5;
            break;
            
        case LSAuthenticationStateLogin:
            return 2;
            break;
            
        default:
            break;
    }
    return 0;
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

- (void)configureCell:(LSInputTableViewCell *)cell forIndexPath:(NSIndexPath *)path
{
    cell.textField.text = nil;
    cell.textField.delegate = self;
    cell.textField.returnKeyType = UIReturnKeyNext;
    cell.textField.enablesReturnKeyAutomatically = YES;
    switch (self.authenticationState) {
        case LSAuthenticationStateLogin:
            switch (path.row) {
                case 0:
                    [cell setGuideText:@"Email:"];
                    [cell setPlaceHolderText:@"Enter Your Email"];
                    cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
                    cell.textField.enablesReturnKeyAutomatically = YES;
                    cell.textField.returnKeyType = UIReturnKeyNext;
                    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
                    cell.textField.text = self.email.text;
                    self.email = cell.textField;
                    break;
                    
                case 1:
                    [cell setGuideText:@"Password:"];
                    [cell setPlaceHolderText:@"Enter Your Password"];
                    cell.textField.secureTextEntry = YES;
                    cell.textField.returnKeyType = UIReturnKeySend;
                    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    cell.textField.text = self.password.text;
                    self.password = cell.textField;
                    break;
                    
                default:
                    break;
            }
            break;
            
        case LSAuthenticationStateRegister:
            switch (path.row) {
                case 0:
                    [cell setGuideText:@"First Name:"];
                    [cell setPlaceHolderText:@"Enter Your First Name"];
                    cell.textField.secureTextEntry = NO;
                    cell.textField.enablesReturnKeyAutomatically = YES;
                    cell.textField.returnKeyType = UIReturnKeyNext;
                    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                    cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
                    cell.textField.text = self.firstName.text;
                    self.firstName = cell.textField;
                    break;
                    
                case 1:
                    [cell setGuideText:@"Last Name:"];
                    [cell setPlaceHolderText:@"Enter Your Last Name"];
                    cell.textField.secureTextEntry = NO;
                    cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
                    cell.textField.enablesReturnKeyAutomatically = YES;
                    cell.textField.returnKeyType = UIReturnKeyNext;
                    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                    cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
                    cell.textField.text = self.lastName.text;
                    self.lastName = cell.textField;
                    break;
                    
                case 4:
                    [cell setGuideText:@"Confirmation:"];
                    [cell setPlaceHolderText:@"Confirm It Please"];
                    cell.textField.secureTextEntry = YES;
                    cell.textField.returnKeyType = UIReturnKeySend;
                    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    cell.textField.text = self.confirmation.text;
                    self.confirmation = cell.textField;
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(LSInputTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing && indexPath.row == 0) {
       [cell.textField becomeFirstResponder];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.isEditing && self.authenticationState == LSAuthenticationStateRegister) {
        return 20;
    } else if (self.isEditing && self.authenticationState == LSAuthenticationStateLogin) {
        return 60;
    } else if (self.authenticationState == LSAuthenticationStateRegister) {
        return 140;
    }
    return 200;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 240;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    self.tableViewHeader = [LSAuthenticationTableViewHeader new];
    if (self.isEditing) {
        self.tableViewHeader.showsContent = NO;
    } else {
        self.tableViewHeader.showsContent = YES;
    }
    return self.tableViewHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    LSAuthenticationTableViewFooter *footer = [LSAuthenticationTableViewFooter new];
    footer.authenticationState = self.authenticationState;
    footer.delegate = self;
    return footer;
}

- (void)authenticationTableViewFooter:(LSAuthenticationTableViewFooter *)tableViewFooter primaryActionButtonTappedWithAuthenticationState:(LSAuthenticationState)authenticationState
{
    switch (authenticationState) {
        case LSAuthenticationStateLogin:
            if (self.isEditing) {
                [self loginTappedWithEmail:self.email.text password:self.password.text];
            } else {
                [self setEditing:YES animated:YES];
                [self.email becomeFirstResponder];
            }
            break;
            
        case LSAuthenticationStateRegister:
            if (self.isEditing) {
                [self registerTapped];
            } else {
                [self setEditing:YES animated:YES];
                [self.firstName becomeFirstResponder];
            }
            break;
            
        default:
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Production - Prod", @"Production - Sandbox", @"Staging", @"Dev-1", nil];
    [actionSheet showInView:self.view];
}


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

    [self.tableViewHeader setShowsContent:!editing];
}

- (void)configureTableViewForAuthenticationState:(LSAuthenticationState)authenticationState
{
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:0 inSection:0],
                            [NSIndexPath indexPathForRow:1 inSection:0],
                            [NSIndexPath indexPathForRow:4 inSection:0]];
    [self.tableView beginUpdates];
    switch (authenticationState) {
        case LSAuthenticationStateLogin:
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case LSAuthenticationStateRegister:
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        default:
            break;
    }
    [self.tableView endUpdates];
}

#pragma mark
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch (self.authenticationState) {
        case LSAuthenticationStateLogin:
            if (textField == self.email) {
                [self.password becomeFirstResponder];
            } else if (textField == self.password) {
                [self loginTappedWithEmail:self.email.text password:self.password.text];
            }
            break;
            
        case LSAuthenticationStateRegister:
            if (textField == self.firstName) {
                [self.lastName becomeFirstResponder];
            } else if (textField == self.lastName) {
                [self.email becomeFirstResponder];
            } else if (textField == self.email) {
                [self.password becomeFirstResponder];
            } else if (textField == self.password) {
                [self.confirmation becomeFirstResponder];
            } else if (textField == self.confirmation) {
                [self registerTapped];
            }
            break;
            
        default:
            break;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self setEditing:YES animated:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (void)loginTappedWithEmail:(NSString *)email password:(NSString *)password
{
    [SVProgressHUD showWithStatus:@"Requesting Nonce"];
    [self.applicationController.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        if (nonce) {
            NSLog(@"Nonce Created");
            [SVProgressHUD showWithStatus:@"Requesting Identity Token"];
            [self.applicationController.APIManager authenticateWithEmail:email password:password nonce:nonce completion:^(NSString *identityToken, NSError *error) {
                if (identityToken) {
                    NSLog(@"Identity Token Created");
                    [SVProgressHUD showWithStatus:@"Authenticating With Layer"];
                    [self.applicationController.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                        if (authenticatedUserID) {
                            NSLog(@"User Authenticated");
                            [SVProgressHUD dismiss];
                        } else {
                            LSAlertWithError(error);
                            [SVProgressHUD dismiss];
                        }
                    }];
                } else {
                    LSAlertWithError(error);
                    [SVProgressHUD dismiss];
                }
            }];
        } else {
            LSAlertWithError(error);
            [SVProgressHUD dismiss];
        }
    }];
}

- (void)registerTapped
{
    LSUser *user = [LSUser new];
    user.firstName = self.firstName.text;
    user.lastName = self.lastName.text;
    user.email = self.email.text;
    user.password = self.password.text;
    user.passwordConfirmation = self.confirmation.text;
    
    [SVProgressHUD show];
    [self.applicationController.APIManager registerUser:user completion:^(LSUser *user, NSError *error) {
        if (user) {
            [self.applicationController.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
                if (nonce) {
                    [self.applicationController.APIManager authenticateWithEmail:user.email password:user.password nonce:nonce completion:^(NSString *identityToken, NSError *error) {
                        if (identityToken) {
                            [self.applicationController.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                                if (authenticatedUserID) {
                                    [SVProgressHUD dismiss];
                                } else {
                                    LSAlertWithError(error);
                                    [SVProgressHUD dismiss];
                                }
                            }];
                        } else {
                            LSAlertWithError(error);
                            [SVProgressHUD dismiss];
                        }
                    }];
                } else {
                    LSAlertWithError(error);
                    [SVProgressHUD dismiss];
                }
            }];
        } else {
            LSAlertWithError(error);
            [SVProgressHUD dismiss];
        }
    }];
}

- (void)resetState;
{
    self.authenticationState = LSAuthenticationStateLogin;
    [self setEditing:NO animated:YES];
    self.firstName.text = nil;
    self.lastName.text = nil;
    self.email.text = nil;
    self.password.text = nil;
    self.confirmation.text = nil;
    [self.tableView reloadData];
}

@end
