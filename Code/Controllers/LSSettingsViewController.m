//
//  LSSettingsViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 10/20/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSSettingsViewController.h"
#import "LYRUIConstants.h"
#import "SVProgressHUD.h"
#import "LSSettingsHeaderView.h"
#import "LSCenterTextTableViewCell.h"
#import "LSStyleValue1TableViewCell.h"

typedef NS_ENUM(NSInteger, LSSettingsTableSection) {
    LSSettingsTableSectionNotifications,
    LSSettingsTableSectionDebug,
    LSSettingsTableSectionStatistics,
    LSSettingsTableSectionLogOut,
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

@interface LSSettingsViewController () <UITextFieldDelegate>

@property (nonatomic) NSUInteger conversationsCount;
@property (nonatomic) NSUInteger messagesCount;
@property (nonatomic) NSUInteger unreadMessagesCount;
@property (nonatomic) LSSettingsHeaderView *headerView;
@property (nonatomic) NSUInteger averageSend;

@end

@implementation LSSettingsViewController

NSString *const LSSettingsViewControllerTitle = @"Settings";
NSString *const LSSettingsTableViewAccessibilityIdentifier = @"Settings Table View";
NSString *const LSSettingsHeaderAccessibilitLabel = @"Settings Header";

NSString *const LSPushNotificationSettingSwitch = @"Push Notification Setting Switch";
NSString *const LSLocalNotificationSettingSwitch = @"Local Notification Setting Switch";
NSString *const LSDebugModeSettingSwitch = @"Debug Mode Setting Switch";

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
        self.title = LSSettingsViewControllerTitle;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchConversationStatistics];
    
    [self.tableView registerClass:[LSStyleValue1TableViewCell class] forCellReuseIdentifier:LSDefaultCellIdentifier];
    [self.tableView registerClass:[LSCenterTextTableViewCell class] forCellReuseIdentifier:LSCenterTextCellIdentifier];
    
    // Left navigation item
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(doneTapped:)];
    doneButton.accessibilityLabel = @"Done";
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.headerView = [LSSettingsHeaderView headerViewWithUser:self.applicationController.APIManager.authenticatedSession.user];
    self.headerView.frame = CGRectMake(0, 0, 320, 148);
    self.headerView.accessibilityLabel = LSSettingsHeaderAccessibilitLabel;
    if (self.applicationController.layerClient.isConnected){
        [self.headerView updateConnectedStateWithString:LSConnected];
    } else {
        [self.headerView updateConnectedStateWithString:LSDisconnected];
    }
    
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.sectionHeaderHeight = 48.0f;
    self.tableView.sectionFooterHeight = 0.0f;
    self.tableView.rowHeight = 44.0f;
    self.tableView.accessibilityIdentifier = LSSettingsTableViewAccessibilityIdentifier;
    
    [self addConnectionObservers];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource

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
            
        case LSSettingsTableSectionLogOut:
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
            UISwitch *switchControl = [self switchForCell];
            switch ((LSNotificationsTableRow)indexPath.row) {
                case LSNotificationsTableRowSendPush:
                    cell.textLabel.text = @"Send Push Notifications";
                    switchControl.accessibilityLabel = LSPushNotificationSettingSwitch;
                    switchControl.on = self.applicationController.shouldSendPushText;
                    cell.accessoryView = switchControl;
                    break;
                    
                case LSNotificationsTableRowDisplayLocal:
                    cell.textLabel.text = @"Display Local Notifications";
                    switchControl.accessibilityLabel = LSLocalNotificationSettingSwitch;
                    switchControl.on = self.applicationController.shouldDisplayLocalNotifications;
                    cell.accessoryView = switchControl;
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
                    cell.textLabel.text = @"Debug Mode";
                    UISwitch *switchControl = [self switchForCell];
                    switchControl.accessibilityLabel = LSDebugModeSettingSwitch;
                    switchControl.on = self.applicationController.debugModeEnabled;
                    cell.accessoryView = switchControl;
                }
                    break;

                case LSDebugTableRowSyncInterval: {
                    cell.textLabel.text = @"Synchronization Interval";
                    UITextField *syncIntervalLabel = [[UITextField alloc] init];
                    syncIntervalLabel.delegate = self;
                    syncIntervalLabel.text = [NSString stringWithFormat:@"%@", [self.applicationController.layerClient valueForKeyPath:@"synchronizationManager.syncInterval"]];
                    [syncIntervalLabel sizeToFit];
                    cell.accessoryView = syncIntervalLabel;
                }
                    break;

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
                case LSStatisticsTableRowConversations:
                    cell.textLabel.text = [NSString stringWithFormat:@"Conversations:"];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.conversationsCount];
                    break;
                    
                case LSStatisticsTableRowMessages:
                    cell.textLabel.text = [NSString stringWithFormat:@"Messages:"];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.messagesCount];
                    break;
                    
                case LSStatisticsTableRowUnread:
                    cell.textLabel.text = [NSString stringWithFormat:@"Unread Messages:"];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.unreadMessagesCount];
                    break;
                    
                case LSStatisticsTableRowCount:
                    break;
            }
            return cell;
        }
        
        case LSSettingsTableSectionLogOut: {
            LSCenterTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSCenterTextCellIdentifier forIndexPath:indexPath];
            cell.centerTextLabel.text = @"Log Out";
            cell.centerTextLabel.textColor = LYRUIRedColor();
            return cell;
        }
            
        case LSSettingsTableSectionCount:
            return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch ((LSSettingsTableSection)section) {
        case LSSettingsTableSectionNotifications:
            return @"Notifications";

        case LSSettingsTableSectionDebug:
            return @"Debug";

        case LSSettingsTableSectionStatistics:
            return @"Statistics";

        case LSSettingsTableSectionLogOut:
        case LSSettingsTableSectionCount:
            return nil;
    }
}

#pragma mark - Cell Configuration

- (UITableViewCell *)defaultCellForIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSDefaultCellIdentifier forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = nil;
    return cell;
}

- (UISwitch *)switchForCell
{
    UISwitch *switchControl = [[UISwitch alloc] init];
    [switchControl addTarget:self action:@selector(switchSwitched:) forControlEvents:UIControlEventValueChanged];
    return switchControl;
}

#pragma mark - UITableViewDelegate

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
        
        case LSSettingsTableSectionLogOut:
            [self logOut];
            break;
            
        case LSSettingsTableSectionNotifications:
        case LSSettingsTableSectionStatistics:
        case LSSettingsTableSectionCount:
            break;
    }
}

#pragma mark - Actions

- (void)switchSwitched:(UISwitch *)switchControl
{
    CGPoint switchControlCenter = [self.tableView convertPoint:switchControl.center fromView:switchControl.superview];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:switchControlCenter];
    switch ((LSSettingsTableSection)indexPath.section) {
        case LSSettingsTableSectionNotifications:
            switch ((LSNotificationsTableRow)indexPath.row) {
                case LSNotificationsTableRowSendPush:
                    self.applicationController.shouldSendPushText = switchControl.on;
                    break;
                    
                case LSNotificationsTableRowDisplayLocal:
                    self.applicationController.shouldDisplayLocalNotifications = switchControl.on;
                    break;
                    
                case LSNotificationsTableRowCount:
                    break;
            }
            break;
            
        case LSSettingsTableSectionDebug:
            switch ((LSDebugTableRow)indexPath.row) {
                case LSDebugTableRowMode:
                    self.applicationController.debugModeEnabled = switchControl.on;
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
        case LSSettingsTableSectionLogOut:
        case LSSettingsTableSectionCount:
            break;
    }
}

- (void)doneTapped:(UIControl *)sender
{
    [self.settingsDelegate settingsViewControllerDidFinish:self];
}

#pragma mark - UIAlertViewDelegate

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

#pragma mark - Helpers

- (void)fetchConversationStatistics
{
    self.conversationsCount = [self.applicationController.layerClient countOfConversations];
    self.messagesCount = [self.applicationController.layerClient countOfMessages];
    self.unreadMessagesCount = [self.applicationController.layerClient countOfUnreadMessages];
}

- (void)showAlertViewForDebuggingWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Copy"
                                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)logOut
{
    [self.settingsDelegate logoutTappedInSettingsViewController:self];
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.applicationController.layerClient setValue:@(textField.text.intValue) forKeyPath:@"synchronizationManager.syncInterval"];
    return YES;
}

@end
