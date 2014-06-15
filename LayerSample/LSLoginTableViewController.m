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
#import "LSAlertView.h"
#import "LSParseController.h"
#import "LSAppDelegate.h"
#import "LSUserManager.h"

@interface LSLoginTableViewController ()

@end

@implementation LSLoginTableViewController

#define kCellIdentifier     @"cell"
#define kLayerColor     [UIColor colorWithRed:36.0f/255.0f green:166.0f/255.0f blue:225.0f/255.0f alpha:1.0]
#define kLayerFont      @"Avenir-Medium"

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Login";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[LSInputTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    [self addLoginButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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
    LSInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (void) configureCell:(LSInputTableViewCell *)cell forIndexPath:(NSIndexPath *)path
{
    switch (path.row) {
        case 0:
            [cell setText:@"Username"];
            [cell.textField setAccessibilityLabel:@"Username"];
            break;
        case 1:
            [cell setText:@"Password"];
            [cell.textField setAccessibilityLabel:@"Password"];
            cell.textField.secureTextEntry = TRUE;
            break;
        default:
            break;
    }
}

- (void)addLoginButton
{
    CGRect rect = CGRectMake(0, 0, 280, 60);
    LSButton *button = [[LSButton alloc] initWithFrame:rect];
    [button setText:@"Login"];
    [button setFont:[UIFont fontWithName:kLayerFont size:20]];
    [button.layer setCornerRadius:4.0f];
    [button setBackgroundColor:kLayerColor];
    [button setAccessibilityLabel:@"LoginButton"];
    button.center = self.view.center;
    button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y - 90, button.frame.size.width, button.frame.size.height);
    [button addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
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

