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

typedef NS_ENUM(NSInteger, LSNotificationsTableRow) {
    LSNotificationsTableRowSendPush,
    LSNotificationsTableRowDisplayLocal,
    LSNotificationsTableRowCount,
};

typedef NS_ENUM(NSInteger, LSDebugTableRow) {
    LSDebugTableRowMode,
    LSDebugTableRowSyncInterval,
    LSDebugTableRowVersion,
    LSDebugTableRowBuild,
    LSDebugTableRowHost,
    LSDebugTableRowUserID,
    LSDebugTableRowDeviceToken,
    LSDebugTableRowCount,
};

typedef NS_ENUM(NSInteger, LSStatisticsTableRow) {
    LSStatisticsTableRowConversations,
    LSStatisticsTableRowMessages,
    LSStatisticsTableRowUnread,
    LSStatisticsTableRowCount,
};

@interface LSSettingsTableViewController () <UITextFieldDelegate>

@property (nonatomic) NSUInteger conversationsCount;
@property (nonatomic) NSUInteger messagesCount;
@property (nonatomic) NSUInteger unreadMessagesCount;
@property (nonatomic) LSSettingsHeaderView *headerView;
@property (nonatomic) NSUInteger averageSend;

@end

@implementation LSSettingsTableViewController

static NSString *const LSDefaultCellIdentifier = @"defaultTableViewCell";
static NSString *const LSCenterTextCellIdentifier = @"centerContentTableViewCell";

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
    
    [self fetchConversationStatistics];
    
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
    if (self.applicationController.layerClient.isConnected){
        [self.headerView updateConnectedStateWithString:LSConnected];
    } else {
        [self.headerView updateConnectedStateWithString:LSDisconnected];
    }
    
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.sectionHeaderHeight = 48.0f;
    self.tableView.sectionFooterHeight = 0.0f;

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
            return LSNotificationsTableRowCount;
            
        case LSSettingsTableSectionDebug:
            return LSDebugTableRowCount;
            
        case LSSettingsTableSectionStatistics:
            return LSStatisticsTableRowCount;
            
        case LSSettingsTableSectionLogout:
            return 1;
            
        case LSSettingsTableSectionCount:
            return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((LSSettingsTableSection)indexPath.section) {
            
        case LSSettingsTableSectionNotifications: {
            UITableViewCell *cell = [self defaultCellForIndexPath:indexPath];
            LSSwitch *radioSwitch = [self switchForIndexPath:indexPath];
            switch ((LSNotificationsTableRow)indexPath.row) {
                case LSNotificationsTableRowSendPush:
                    cell.textLabel.text = @"Send Push Notifications";
                    radioSwitch.on = self.applicationController.shouldSendPushText;
                    cell.accessoryView = radioSwitch;
                    break;
                    
                case LSNotificationsTableRowDisplayLocal:
                    cell.textLabel.text = @"Display Local Notifications";
                    radioSwitch.on = self.applicationController.shouldDisplayLocalNotifications;
                    cell.accessoryView = radioSwitch;
                    break;
                    
                case LSNotificationsTableRowCount:
                    break;
            }
            return cell;
        }
            
        case LSSettingsTableSectionDebug: {
            UITableViewCell *cell = [self defaultCellForIndexPath:indexPath];
            switch ((LSDebugTableRow)indexPath.row) {
                case LSDebugTableRowMode: {
                    cell.textLabel.text = @"Debug Mode ";
                    LSSwitch *radioSwitch = [self switchForIndexPath:indexPath];
                    radioSwitch.on = self.applicationController.debugModeEnabled;
                    cell.accessoryView = radioSwitch;
                    break;
                }

                case LSDebugTableRowSyncInterval: {
                    cell.textLabel.text = @"Synchronization Interval";
                    UITextField *syncIntervalLabel = [[UITextField alloc] init];
                    syncIntervalLabel.delegate = self;
                    syncIntervalLabel.text = [NSString stringWithFormat:@"%@", [self.applicationController.layerClient valueForKeyPath:@"synchronizationManager.syncInterval"]];
                    [syncIntervalLabel sizeToFit];
                    cell.accessoryView = syncIntervalLabel;
                    break;
                }
                    
                case LSDebugTableRowVersion:
                    cell.textLabel.text = [NSString stringWithFormat:@"Version: %@", [LSApplicationController versionString]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case LSDebugTableRowBuild:
                    cell.textLabel.text = [NSString stringWithFormat:@"Build: %@", [LSApplicationController buildInformationString]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case LSDebugTableRowHost:
                    cell.textLabel.text = [NSString stringWithFormat:@"Host: %@", [LSApplicationController layerServerHostname]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case LSDebugTableRowUserID:
                    cell.textLabel.text = [NSString stringWithFormat:@"User ID: %@", self.applicationController.layerClient.authenticatedUserID];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case LSDebugTableRowDeviceToken:
                    cell.textLabel.text = [NSString stringWithFormat:@"Device Token: %@", [self.applicationController.deviceToken description]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case LSDebugTableRowCount:
                    break;
            }
            return cell;
        }
            
        case LSSettingsTableSectionStatistics: {
            UITableViewCell *cell = [self defaultCellForIndexPath:indexPath];
            switch ((LSStatisticsTableRow)indexPath.row) {
                case LSStatisticsTableRowConversations: {
                    cell.textLabel.text = [NSString stringWithFormat:@"Conversations:"];
                    UILabel *conversationsLabel = [[UILabel alloc] init];
                    conversationsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.conversationsCount];
                    conversationsLabel.font = cell.textLabel.font;
                    [conversationsLabel sizeToFit];
                    cell.accessoryView = conversationsLabel;
                }
                    break;
                    
                case LSStatisticsTableRowMessages: {
                    cell.textLabel.text = [NSString stringWithFormat:@"Messages:"];
                    UILabel *messagesLabel = [[UILabel alloc] init];
                    messagesLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.messagesCount];
                    messagesLabel.font = cell.textLabel.font;
                    [messagesLabel sizeToFit];
                    cell.accessoryView = messagesLabel;
                }
                    break;
                    
                case LSStatisticsTableRowUnread: {
                    cell.textLabel.text = [NSString stringWithFormat:@"Unread Messages:"];
                    UILabel *unreadMessagesLabel = [[UILabel alloc] init];
                    unreadMessagesLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.unreadMessagesCount];
                    unreadMessagesLabel.font = cell.textLabel.font;
                    [unreadMessagesLabel sizeToFit];
                    cell.accessoryView = unreadMessagesLabel;
                }
                    break;
                    
                case LSStatisticsTableRowCount:
                    break;
                    
            }
            return cell;
        }
        
        case LSSettingsTableSectionLogout: {
            LSCenterTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSCenterTextCellIdentifier forIndexPath:indexPath];
            [cell setCenterText:@"Log Out"];
            cell.centerTextLabel.textColor = LYRUIRedColor();
            return cell;
        }
            
        case LSSettingsTableSectionCount:
            return nil;
    }
}

- (UITableViewCell *)defaultCellForIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSDefaultCellIdentifier forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = nil;
    return cell;
}

- (LSSwitch *)switchForIndexPath:(NSIndexPath *)indexPath
{
    LSSwitch *switchControl = [[LSSwitch alloc] init];
    switchControl.indexPath = indexPath;
    [switchControl addTarget:self action:@selector(switchSwitched:) forControlEvents:UIControlEventTouchUpInside];
    return switchControl;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((LSSettingsTableSection)indexPath.section) {
        case LSSettingsTableSectionDebug:
            switch ((LSDebugTableRow)indexPath.row) {
                case LSDebugTableRowVersion:
                    [self showAlertViewForDebuggingWithTitle:@"Version" message:[LSApplicationController versionString]];
                    break;
                    
                case LSDebugTableRowBuild:
                    [self showAlertViewForDebuggingWithTitle:@"Build" message:[LSApplicationController buildInformationString]];
                    break;
                    
                case LSDebugTableRowHost:
                    [self showAlertViewForDebuggingWithTitle:@"Host" message:[LSApplicationController layerServerHostname]];
                    break;
                    
                case LSDebugTableRowUserID:
                    [self showAlertViewForDebuggingWithTitle:@"User ID" message:self.applicationController.layerClient.authenticatedUserID];
                    break;
                    
                case LSDebugTableRowDeviceToken:
                    if (self.applicationController.deviceToken) {
                        [self showAlertViewForDebuggingWithTitle:@"Device Token" message:[self.applicationController.deviceToken description]];
                    }
                    break;
                    
                case LSDebugTableRowMode:
                case LSDebugTableRowSyncInterval:
                case LSDebugTableRowCount:
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch ((LSSettingsTableSection)section) {
        case LSSettingsTableSectionNotifications:
            return @"Notifications";
            
        case LSSettingsTableSectionDebug:
            return  @"Debug";
            
        case LSSettingsTableSectionStatistics:
            return @"Statistics";
            
        case LSSettingsTableSectionLogout:
        case LSSettingsTableSectionCount:
            return nil;
    }
}

- (void)fetchConversationStatistics
{
    self.conversationsCount = [self.applicationController.layerClient countOfConversations];
    self.messagesCount = [self.applicationController.layerClient countOfMessages];
    self.unreadMessagesCount = [self.applicationController.layerClient countOfUnreadMessages];
}

- (void)switchSwitched:(UIControl *)sender
{
    LSSwitch *radioButton = (LSSwitch *)sender;
    NSIndexPath *indexPath = [(LSSwitch *)sender indexPath];
    switch ((LSSettingsTableSection)indexPath.section) {
        case LSSettingsTableSectionNotifications:
            switch ((LSNotificationsTableRow)indexPath.row) {
                case LSNotificationsTableRowSendPush:
                    self.applicationController.shouldSendPushText = radioButton.on;
                    break;
                    
                case LSNotificationsTableRowDisplayLocal:
                    self.applicationController.shouldDisplayLocalNotifications = radioButton.on;
                    break;
                    
                case LSNotificationsTableRowCount:
                    break;
            }
            break;
            
        case LSSettingsTableSectionDebug:
            switch ((LSDebugTableRow)indexPath.row) {
                case LSDebugTableRowMode:
                    self.applicationController.debugModeEnabled = radioButton.on;
                    break;
                    
                case LSDebugTableRowSyncInterval:
                case LSDebugTableRowVersion:
                case LSDebugTableRowBuild:
                case LSDebugTableRowHost:
                case LSDebugTableRowUserID:
                case LSDebugTableRowDeviceToken:
                case LSDebugTableRowCount:
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

- (void)showAlertViewForDebuggingWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Copy" otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = alertView.message;
            [SVProgressHUD showSuccessWithStatus:@"Copied"];
        }
            break;
            
        default:
            break;
    }
}

- (void)logOut
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.settingsDelegate logoutTappedInSettingsTableViewController:self];
    }];
}

# pragma mark - Layer Connection State Monitoring

- (void)addConnectionObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerDidConnect:) name:LYRClientDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerDidDisconnect:) name:LYRClientDidDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerIsConnecting:) name:LYRClientWillAttemptToConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerDidLoseConnection:) name:LYRClientDidLoseConnectionNotification object:nil];
}

- (void)layerDidConnect:(NSNotification *)notification
{
    [self.headerView updateConnectedStateWithString:LSConnected];
}

- (void)layerDidDisconnect:(NSNotification *)notification
{
    [self.headerView updateConnectedStateWithString:LSDisconnected];
}

- (void)layerIsConnecting:(NSNotification *)notification
{
    [self.headerView updateConnectedStateWithString:LSConnecting];
}

- (void)layerDidLoseConnection:(NSNotification *)notification
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
