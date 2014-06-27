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
    
    [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        if (nonce) {
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            configuration.HTTPAdditionalHeaders = @{ @"Accept": @"application/json", @"Content-Type": @"application/json" };
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
            NSURL *URL = [NSURL URLWithString:@"http://10.66.0.35:8080/users/sign_in.json"];
            NSDictionary *parameters = @{ @"user": @{ @"email": usernameCell.textField.text, @"password":  passwordCell.textField.text }, @"nonce": nonce };
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
            request.HTTPMethod = @"POST";
            request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
            [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSLog(@"Got response: %@, data: %@, error: %@", response, data, error);
                if (response && data) {
                    NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"Get the info: %@", info);
                    [self.layerClient authenticateWithIdentityToken:info[@"layer_identity_token"] completion:^(NSString *authenticatedUserID, NSError *error) {
                        NSLog(@"Authenticated with layer userID:%@, error=%@", authenticatedUserID, error);
                    }];
                } else {
                    NSLog(@"Failed with error: %@", error);
                }
            }] resume];
        } else {
            NSLog(@"Failed obtaining nonce: %@", error);
        }
    }];
//    LSUserManager *manager = [[LSUserManager alloc] init];
//    [manager loginWithEmail:usernameCell.textField.text password:passwordCell.textField.text completion:^(LSUser *user, NSError *error) {
//        if (!error) {
//            [self.delegate loginViewControllerDidFinish];
//        } else {
//            [self.delegate loginViewControllerDidFailWithError:error];
//        }
//       
//    }];
}

@end

