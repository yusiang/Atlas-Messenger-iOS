//
//  LSSettingsViewControllerTableViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 10/20/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSSettingsTableViewController.h"
#import "LSSwitch.h"
#import "LYRUIConstants.h"
#import "SVProgressHUD.h"
#import "LSSettingsHeaderView.h"
#import "LSCenterTextTableViewCell.h"

typedef NS_ENUM(NSInteger, LSSettingsTableSection) {
    LSSettingsTableSectionNotifications,
    LSSettingsTableSectionDebug,
    LSSettingsTableSectionStatistics,
    LSSettingsTableSectionLogout,
    LSSettingsTableSectionCount,
};

@interface LSSettingsTableViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSDictionary *conversationStatistics;
@property (nonatomic) LSSettingsHeaderView *headerView;
@property (nonatomic) NSUInteger averageSend;

@end

@implementation LSSettingsTableViewController

static NSString *const LSDefaultCellIdentifier = @"defaultTableViewCell";
static NSString *const LSCenterTextCellIdentifier = @"centerContentTableViewCell";

static NSString *const LSConversationCountKey = @"LSConversationCount";
static NSString *const LSMessageCountKey = @"LSMessageCount";
static NSString *const LSUnreadMessageCountKey = @"LSUnreadMessageCount";

static NSString *const LSConnected = @"Connected";
static NSString *const LSDisconnected = @"Disconnected";
static NSString *const LSLostConnection = @"Lost Connection";
static NSString *const LSConnecting = @"Connecting";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Settings";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.conversationStatistics = [self fetchConversationStatistics];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:LSDefaultCellIdentifier];
    [self.tableView registerClass:[LSCenterTextTableViewCell class] forCellReuseIdentifier:LSCenterTextCellIdentifier];
    
    // Left navigation item
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(doneTapped:)];
    doneButton.accessibilityLabel = @"Done";
    [self.navigationItem setRightBarButtonItem:doneButton];
    
    self.headerView = [LSSettingsHeaderView headerViewWithUser:self.applicationController.APIManager.authenticatedSession.user];
    self.headerView.frame = CGRectMake(0, 0, 320, 148);
    self.headerView.backgroundColor = [UIColor whiteColor];
    [self.headerView updateConnectedStateWithString:@"Connected"];
    
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.sectionFooterHeight = 0.0f;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.applicationController.layerClient.isConnected){
        [self.headerView updateConnectedStateWithString:LSConnected];
    } else {
        [self.headerView updateConnectedStateWithString:LSDisconnected];
    }
    [self addConnectionObservers];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return LSSettingsTableSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch ((LSSettingsTableSection)section) {
        case LSSettingsTableSectionNotifications:
            return 2;
            break;
            
        case LSSettingsTableSectionDebug:
            return 6;
            break;
            
        case LSSettingsTableSectionStatistics:
            return 3;
            break;
            
        case LSSettingsTableSectionLogout:
            return 1;
            break;
            
        case LSSettingsTableSectionCount:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSDefaultCellIdentifier];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    LSSwitch *radioSwitch = [[LSSwitch alloc] init];
    radioSwitch.indexPath = indexPath;
    [radioSwitch addTarget:self action:@selector(switchSwitched:) forControlEvents:UIControlEventTouchUpInside];
    
    switch ((LSSettingsTableSection)indexPath.section) {
            
        case LSSettingsTableSectionNotifications: {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Send Push Notifications";
                    radioSwitch.on = self.applicationController.shouldSendPushText;
                    cell.accessoryView = radioSwitch;
                    break;
                    
                case 1:
                    cell.textLabel.text = @"Display Local Notifications";
                    radioSwitch.on = self.applicationController.shouldDisplayLocalNotifications;
                    cell.accessoryView = radioSwitch;
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case LSSettingsTableSectionDebug: {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Debug Mode ";
                    radioSwitch.on = self.applicationController.debugModeEnabled;
                    cell.accessoryView = radioSwitch;
                    break;
                    
                case 1: {
                    cell.textLabel.text = @"Synchronization Interval";
                    UITextField *syncIntervalLabel = [[UITextField alloc] init];
                    syncIntervalLabel.delegate = self;
                    syncIntervalLabel.text = [NSString stringWithFormat:@"%@", [self.applicationController.layerClient valueForKeyPath:@"synchronizationManager.syncInterval"]];
                    [syncIntervalLabel sizeToFit];
                    cell.accessoryView = syncIntervalLabel;
                    break;
                }
                    
                case 2:
                    cell.textLabel.text = [NSString stringWithFormat:@"Version: %@", [LSApplicationController versionString]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case 3:
                    cell.textLabel.text = [NSString stringWithFormat:@"Build: %@", [LSApplicationController buildInformationString]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case 4:
                    cell.textLabel.text = [NSString stringWithFormat:@"Host: %@", [LSApplicationController layerServerHostname]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case 5:
                    cell.textLabel.text = [NSString stringWithFormat:@"UserID: %@", self.applicationController.layerClient.authenticatedUserID];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case 6:
                    cell.textLabel.text = [NSString stringWithFormat:@"Device Token: %@", [self.applicationController.deviceToken description]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case LSSettingsTableSectionStatistics: {
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = [NSString stringWithFormat:@"Conversations:"];
                    UILabel *conversationsLabel = [[UILabel alloc] init];
                    conversationsLabel.text = [[self.conversationStatistics objectForKey:LSConversationCountKey]stringValue];
                    conversationsLabel.font = cell.textLabel.font;
                    [conversationsLabel sizeToFit];
                    cell.accessoryView = conversationsLabel;
                }
                    break;
                    
                case 1: {
                    cell.textLabel.text = [NSString stringWithFormat:@"Messages:"];
                    UILabel *messagesLabel = [[UILabel alloc] init];
                    messagesLabel.text = [[self.conversationStatistics objectForKey:LSMessageCountKey]stringValue];
                    messagesLabel.font = cell.textLabel.font;
                    [messagesLabel sizeToFit];
                    cell.accessoryView = messagesLabel;
                }
                    break;
                    
                case 2: {
                    cell.textLabel.text = [NSString stringWithFormat:@"Unread Messages:"];
                    UILabel *unreadMessagesLabel = [[UILabel alloc] init];
                    unreadMessagesLabel.text = [[self.conversationStatistics objectForKey:LSUnreadMessageCountKey]stringValue];
                    unreadMessagesLabel.font = cell.textLabel.font;
                    [unreadMessagesLabel sizeToFit];
                    cell.accessoryView = unreadMessagesLabel;
                }
                    break;
                    
                default:
                    break;
                    
            }
        }
            break;
        
        case LSSettingsTableSectionLogout: {
            LSCenterTextTableViewCell *centerCell = [self.tableView dequeueReusableCellWithIdentifier:LSCenterTextCellIdentifier];
            [centerCell setCenterText:@"Log Out"];
            centerCell.centerTextLabel.textColor = LYRUIRedColor();
            return centerCell;
        }
            break;
            
        case LSSettingsTableSectionCount:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((LSSettingsTableSection)indexPath.section) {
        case LSSettingsTableSectionDebug:
            switch (indexPath.row) {
                case 1:
                    
                    break;
                    
                case 2:
                     [self settingsAlertWithString:[LSApplicationController versionString]];
                    break;
                    
                case 3:
                     [self settingsAlertWithString:[LSApplicationController buildInformationString]];
                    break;
                    
                case 4:
                     [self settingsAlertWithString:[LSApplicationController layerServerHostname]];
                    break;
                    
                case 5:
                     [self settingsAlertWithString:self.applicationController.layerClient.authenticatedUserID];
                    break;
                    
                case 6:
                     [self settingsAlertWithString:[self.applicationController.deviceToken description]];
                    break;
                    
                default:
                    break;
            }
            break;
        
        case LSSettingsTableSectionLogout:
            [self logOut];
            break;
            
        case LSSettingsTableSectionNotifications:
        case LSSettingsTableSectionStatistics:
        case LSSettingsTableSectionCount:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 48;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch ((LSSettingsTableSection)section) {
        case LSSettingsTableSectionNotifications:
            return @"NOTIFICATIONS";
            break;
            
        case LSSettingsTableSectionDebug:
            return  @"DEBUG";
            break;
            
        case LSSettingsTableSectionStatistics:
            return @"STATISTICS";
            break;
            
        case LSSettingsTableSectionLogout:
        case LSSettingsTableSectionCount:
            break;
    }
    return nil;
}

- (NSDictionary *)fetchConversationStatistics
{
    NSUInteger conversationCount = [self.applicationController.layerClient countOfConversations];
    NSUInteger messageCount = [self.applicationController.layerClient countOfMessages];
    NSUInteger unreadMessageCount = [self.applicationController.layerClient countOfUnreadMessages];
    NSDictionary *conversationStatistics = @{LSConversationCountKey : [NSNumber numberWithInteger:conversationCount],
                                             LSMessageCountKey : [NSNumber numberWithInteger:messageCount],
                                             LSUnreadMessageCountKey : [NSNumber numberWithInteger:unreadMessageCount]};
    return conversationStatistics;
}

- (void)switchSwitched:(UIControl *)sender
{
    LSSwitch *radioButton = (LSSwitch *)sender;
    NSIndexPath *indexPath = [(LSSwitch *)sender indexPath];
    switch ((LSSettingsTableSection)indexPath.section) {
        case LSSettingsTableSectionNotifications:
            switch (indexPath.row) {
                case 0:
                    self.applicationController.shouldSendPushText = radioButton.on;
                    break;
                    
                case 1:
                    self.applicationController.shouldDisplayLocalNotifications = radioButton.on;
                    break;
                    
                default:
                    break;
            }
            break;
            
        case LSSettingsTableSectionDebug:
            switch (indexPath.row) {
                case 0:
                    self.applicationController.debugModeEnabled = radioButton.on;
                    break;
                    
                default:
                    break;
            }
            break;
            
        case LSSettingsTableSectionStatistics:
        case LSSettingsTableSectionLogout:
        case LSSettingsTableSectionCount:
            break;
    }
}

- (void)doneTapped:(UIControl *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingsAlertWithString:(NSString *)string
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Layer Talk Settings"
                                                        message:string
                                                       delegate:nil
                                              cancelButtonTitle:@"Copy" otherButtonTitles:@"OK", nil];
    alertView.delegate = self;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            if (self.applicationController.deviceToken) {
                pasteboard.string = alertView.message;
                [SVProgressHUD showSuccessWithStatus:@"Copied"];
            } else {
                [SVProgressHUD showErrorWithStatus:@"No Device Token Available"];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)reloadContacts
{
    [SVProgressHUD showWithStatus:@"Loading Contacts"];
    [self.applicationController.APIManager loadContactsWithCompletion:^(NSSet *contacts, NSError *error) {
        [SVProgressHUD showSuccessWithStatus:@"Contacts Loaded"];
    }];
}

- (void)logOut
{
    [self dismissViewControllerAnimated:TRUE completion:^{
        [self.settingsDelegate logoutTappedInSettingsTableViewController:self];
    }];
}

# pragma mark - Layer Connection State Monitoring

- (void)addConnectionObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerDidConnect) name:LYRClientDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerDidDisconnect) name:LYRClientDidDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerIsConnecting) name:LYRClientWillAttemptToConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerDidLoseConnection) name:LYRClientDidLoseConnectionNotification object:nil];
}

- (void)layerDidConnect
{
    [self.headerView updateConnectedStateWithString:LSConnected];
}

- (void)layerDidDisconnect
{
    [self.headerView updateConnectedStateWithString:LSDisconnected];
}

- (void)layerIsConnecting
{
    [self.headerView updateConnectedStateWithString:LSConnecting];
}

- (void)layerDidLoseConnection
{
    [self.headerView updateConnectedStateWithString:LSLostConnection];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.applicationController.layerClient setValue:@([textField.text intValue]) forKeyPath:@"synchronizationManager.syncInterval"];
    return YES;
}
@end
