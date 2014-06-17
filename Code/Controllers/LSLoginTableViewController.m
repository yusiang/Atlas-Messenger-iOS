//
//  LSLoginTableViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSLoginTableViewController.h"
#import "LSInputTableViewCell.h"
#import "LSConversationListViewController.h"
#import "LSButton.h"
#import "LSUserManager.h"

@interface LSLoginTableViewController ()

@property (nonatomic, strong) LSButton *loginButton;

@end

@implementation LSLoginTableViewController

NSString *const LSLoginlIdentifier = @"loginCellIdentifier";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // SBW: viewDidLoad
        self.title = @"Login";
        self.accessibilityLabel = @"Login Screen";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeLoginButton];
    [self configureLayoutConstraints];
    [self.tableView registerClass:[LSInputTableViewCell class] forCellReuseIdentifier:LSLoginlIdentifier];
}

- (void)initializeLoginButton
{
    self.LoginButton = [[LSButton alloc] initWithText:@"Login"];
    [self.loginButton addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
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
            [cell setText:@"Username"];
            cell.textField.accessibilityLabel = @"Username";
            break;
        case 1:
            [cell setText:@"Password"];
            cell.textField.accessibilityLabel = @"Password";
            cell.textField.secureTextEntry = TRUE;
            break;
        default:
            break;
    }
}

- (void)loginTapped
{
    LSInputTableViewCell *usernameCell = (LSInputTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    LSInputTableViewCell *passwordCell = (LSInputTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];

    if([LSUserManager loginWithEmail:usernameCell.textField.text andPassword:passwordCell.textField.text]) {
        [self.delegate loginSuccess];
    }
}

@end

