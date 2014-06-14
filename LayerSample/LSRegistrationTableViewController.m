//
//  LSRegistrationTableViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSRegistrationTableViewController.h"
#import "LSInputTableViewCell.h"
#import "LSButton.h"
#import "LSAlertView.h"
#import "LSParseController.h"
#import "LSConversationListViewController.h"
#import "LSAppDelegate.h"

@interface LSRegistrationTableViewController ()

@property (nonatomic, strong) LSAlertView *alertView;

@end

@implementation LSRegistrationTableViewController

#define kCellIdentifier     @"cell"
#define kLayerColor     [UIColor colorWithRed:36.0f/255.0f green:166.0f/255.0f blue:225.0f/255.0f alpha:1.0]
#define kLayerFont      @"Avenir-Medium"


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Register";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.alertView = [[LSAlertView alloc] init];
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
    return 4;
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
            [cell setText:@"Full Name"];
            cell.textField.accessibilityLabel = @"Full Name";
            break;
        case 1:
            [cell setText:@"Username"];
            cell.textField.accessibilityLabel = @"Username";
            break;
        case 2:
            [cell setText:@"Password"];
            cell.textField.secureTextEntry = TRUE;
            cell.textField.accessibilityLabel = @"Password";
            break;
        case 3:
            [cell setText:@"Confirm"];
            cell.textField.secureTextEntry = TRUE;
            cell.textField.accessibilityLabel = @"Confirm";
            break;
        default:
            break;
    }
}

- (void)addLoginButton
{
    CGRect rect = CGRectMake(0, 0, 320, 60);
    LSButton *button = [[LSButton alloc] initWithFrame:rect];
    [button setText:@"Register"];
    [button setFont:[UIFont fontWithName:kLayerFont size:20]];
    [button.layer setCornerRadius:4.0f];
    [button setBackgroundColor:kLayerColor];
    [button setAccessibilityLabel:@"Register"];
    button.center = self.view.center;
    button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.size.width, button.frame.size.height);
    [button addTarget:self action:@selector(registerTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)registerTapped
{
    LSInputTableViewCell *fullNameCell = (LSInputTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    LSInputTableViewCell *usernameCell = (LSInputTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    LSInputTableViewCell *passwordCell = (LSInputTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    LSInputTableViewCell *confirmationCell = (LSInputTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    
    if ([self verifyFullName:fullNameCell.textField.text email:usernameCell.textField.text password:passwordCell.textField.text andConfirmation:confirmationCell.textField.text]) {
        LSParseController *parseController = [[LSParseController alloc] init];
        [parseController initializeParseSDK];
        [parseController createParseUserWithEmail:usernameCell.textField.text password:passwordCell.textField.text completion:^(NSError *error) {
            if(!error) {
                [self.delegate registrationSuccessful];
            }
        }];
    }
}

- (BOOL)verifyFullName:(NSString *)fullName email:(NSString *)email password:(NSString *)password andConfirmation:(NSString *)confirmation
{
    if ([email isEqualToString:@""]) {
        [LSAlertView missingEmailAlert];
        return FALSE;
    }
    
    if ([password isEqualToString:@""]|| [confirmation isEqualToString:@""]) {
        [LSAlertView matchingPasswordAlert];
        return FALSE;
    }
        
    if(![password isEqualToString:confirmation]) {
        [LSAlertView matchingPasswordAlert];
        return FALSE;
    }
    if(![self storeFullName:fullName email:email password:password andConfirmation:confirmation]) {
        [LSAlertView existingUsernameAlert];
        return FALSE;
    }
    return TRUE;
}

- (BOOL)storeFullName:(NSString *)fullName email:(NSString *)email password:(NSString *)password andConfirmation:(NSString *)confirmation
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastUserID = [defaults objectForKey:@"lastUserNumber"];
    
    if ([self checkForExistingEmail:email withUserID:lastUserID]) {
        return FALSE;
    }
    
    NSString *userID;
   
    if (lastUserID) {
        double number = [lastUserID doubleValue];
        userID = [NSString stringWithFormat:@"%f", (number + 1)];
    } else {
        userID = [NSString stringWithFormat:@"%d", 1];
    }
    
    NSDictionary *userInfo = @{@"fullName" : fullName,
                               @"email" : email,
                               @"password" : password,
                               @"confirmation" : confirmation,
                               @"userID" : userID};
    
    [defaults setObject:userInfo forKey:userID];
    [defaults setObject:userID forKey:@"lastUserID"];
    [defaults synchronize];
    return TRUE;
}

-(BOOL)checkForExistingEmail:(NSString *)email withUserID:(NSString *)userID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (int i = 0; i < [userID doubleValue]; i++) {
        NSString *existingEmail = [defaults valueForKeyPath:[NSString stringWithFormat:@"%@.email", userID]];
        if ([existingEmail isEqualToString:email]) {
            return TRUE;
        }
    }
    return FALSE;
}

@end
