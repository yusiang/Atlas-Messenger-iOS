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
#import "LSUIConstants.h"
#import "SVPRogressHUD.h"
#import "LSUtilities.h"

@interface LSAuthenticationTableViewController () <LSAuthenticationTableViewFooterDelegate, UITextFieldDelegate, UIScrollViewDelegate>

@property (nonatomic) LSAuthenticationState authenticationState;
@property (nonatomic) UITextField *email;
@property (nonatomic) UITextField *password;
@property (nonatomic) UITextField *firstName;
@property (nonatomic) UITextField *lastName;
@property (nonatomic) UITextField *passwordConfirmation;
@property (nonatomic, strong) LSAuthenticationTableViewHeader *tableViewHeader;
@property (nonatomic, copy) void (^completionBlock)(NSString *authenticatedUserID);
@property (nonatomic) BOOL isEditing;

@end

@implementation LSAuthenticationTableViewController

static NSString *const LSAuthenticationCellIdentifier = @"authenticationCellIdentifier";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        self.authenticationState = LSAuthenticationStateLogin;
        self.isEditing = NO;
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [self.tableView registerClass:[LSInputTableViewCell class] forCellReuseIdentifier:LSAuthenticationCellIdentifier];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setContentOffset:CGPointMake(0, 140)];
    self.authenticationState = LSAuthenticationStateLogin;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    LSInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LSAuthenticationCellIdentifier];
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(LSInputTableViewCell *)cell forIndexPath:(NSIndexPath *)path
{
    cell.textField.delegate = self;
    cell.textField.returnKeyType = UIReturnKeyNext;
    cell.textField.enablesReturnKeyAutomatically = YES;
    
    switch (self.authenticationState) {
        case LSAuthenticationStateLogin:
            switch (path.row) {
                case 0:
                    [cell setText:@"Email"];
                    cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
                    cell.textField.enablesReturnKeyAutomatically = YES;
                    cell.textField.returnKeyType = UIReturnKeyNext;
                    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
                    self.email = cell.textField;
                    self.email.delegate = self;
                    break;
                case 1:
                    [cell setText:@"Password"];
                    cell.textField.secureTextEntry = YES;
                    cell.textField.returnKeyType = UIReturnKeySend;
                    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    self.password = cell.textField;
                    break;
                default:
                    break;
            }
            break;
        case LSAuthenticationStateRegister:
            switch (path.row) {
                case 0:
                    [cell setText:@"First Name"];
                    cell.textField.enablesReturnKeyAutomatically = YES;
                    cell.textField.returnKeyType = UIReturnKeyNext;
                    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
                    self.firstName = cell.textField;
                    break;
                case 1:
                    [cell setText:@"Last Name"];
                    cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
                    cell.textField.enablesReturnKeyAutomatically = YES;
                    cell.textField.returnKeyType = UIReturnKeyNext;
                    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
                    self.lastName = cell.textField;
                    break;
                case 2:
                    [cell setText:@"Email"];
                    cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
                    cell.textField.enablesReturnKeyAutomatically = YES;
                    cell.textField.returnKeyType = UIReturnKeyNext;
                    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    self.email = cell.textField;
                    break;
                case 3:
                    [cell setText:@"Password"];
                    cell.textField.secureTextEntry = YES;
                    cell.textField.returnKeyType = UIReturnKeyNext;
                    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    self.password = cell.textField;
                    break;
                case 4:
                    [cell setText:@"Confirmation"];
                    cell.textField.secureTextEntry = YES;
                    cell.textField.returnKeyType = UIReturnKeySend;
                    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    self.passwordConfirmation = cell.textField;
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
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
    return 200;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    self.tableViewHeader = [LSAuthenticationTableViewHeader new];
    if (self.isEditing) {
        self.tableViewHeader.showsContent = FALSE;
    } else {
        self.tableViewHeader.showsContent = TRUE;
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
    [self setTableViewEditing];
    switch (authenticationState) {
        case LSAuthenticationStateLogin:
            if (self.email.text.length && self.password.text.length) {
                [self loginTapped];
            } else {
                [self.email becomeFirstResponder];
            }
            break;
        case LSAuthenticationStateRegister:
            if (self.firstName.text.length && self.lastName.text.length && self.email.text.length && self.password.text.length && self.passwordConfirmation.text.length) {
                [self registerTapped];
            } else {
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

- (void)setTableViewEditing
{
    self.isEditing = TRUE;
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)setTableViewNotEditing
{
    self.isEditing = FALSE;
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)configureTableViewForAuthenticationState:(LSAuthenticationState)authenticationState
{
    [self.tableView beginUpdates];
    
    switch (authenticationState) {
        case LSAuthenticationStateLogin:
            
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.firstName becomeFirstResponder];
            
            break;
        case LSAuthenticationStateRegister:
            
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.email becomeFirstResponder];
            
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
                [self loginTapped];
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
                [self.passwordConfirmation becomeFirstResponder];
            } else if (textField == self.passwordConfirmation) {
                [self registerTapped];
            }
            break;
        default:
            break;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (void)loginTapped
{
    [SVProgressHUD show];
    
    [self.applicationController.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        if (nonce) {
            [self.applicationController.APIManager authenticateWithEmail:self.email.text password:self.password.text nonce:nonce completion:^(NSString *identityToken, NSError *error) {
                if (identityToken) {
                    [self.applicationController.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                        if (authenticatedUserID) {
                            if (self.completionBlock) self.completionBlock(authenticatedUserID);
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
    LSUser *user = [[LSUser alloc] init];
    [user setFirstName:self.firstName.text];
    [user setLastName:self.lastName.text];
    [user setEmail:self.email.text];
    [user setPassword:self.password.text];
    [user setPasswordConfirmation:self.passwordConfirmation.text];
    
    [SVProgressHUD show];
    [self.applicationController.APIManager registerUser:user completion:^(LSUser *user, NSError *error) {
        if (user) {
            [self.applicationController.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
                if (nonce) {
                    [self.applicationController.APIManager authenticateWithEmail:user.email password:user.password nonce:nonce completion:^(NSString *identityToken, NSError *error) {
                        if (identityToken) {
                            [self.applicationController.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                                if (authenticatedUserID) {
                                    if (self.completionBlock) self.completionBlock(authenticatedUserID);
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

@end
