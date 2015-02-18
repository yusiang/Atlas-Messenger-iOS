//
//  ATLMSettingsViewController.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 10/20/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "ATLMSettingsViewController.h"
#import <Atlas/Atlas.h>
#import "SVProgressHUD.h"
#import "ATLMSettingsHeaderView.h"
#import "ATLMCenterTextTableViewCell.h"
#import "ATLMStyleValue1TableViewCell.h"

typedef NS_ENUM(NSInteger, ATLMSettingsTableSection) {
    ATLMSettingsTableSectionNotifications,
    ATLMSettingsTableSectionDebug,
    ATLMSettingsTableSectionStatistics,
    ATLMSettingsTableSectionLogout,
    ATLMSettingsTableSectionCount,
};

typedef NS_ENUM(NSInteger, ATLMNotificationsTableRow) {
    ATLMNotificationsTableRowSendPush,
    ATLMNotificationsTableRowDisplayLocal,
    ATLMNotificationsTableRowCount,
};

typedef NS_ENUM(NSInteger, ATLMDebugTableRow) {
    ATLMDebugTableRowMode,
    ATLMDebugTableRowSyncInterval,
    ATLMDebugTableRowVersion,
    ATLMDebugTableRowBuild,
    ATLMDebugTableRowHost,
    ATLMDebugTableRowUserID,
    ATLMDebugTableRowDeviceToken,
    ATLMDebugTableRowCount,
};

typedef NS_ENUM(NSInteger, ATLMStatisticsTableRow) {
    ATLMStatisticsTableRowConversations,
    ATLMStatisticsTableRowMessages,
    ATLMStatisticsTableRowUnread,
    ATLMStatisticsTableRowCount,
};

@interface ATLMSettingsViewController () <UITextFieldDelegate>

@property (nonatomic) NSUInteger conversationsCount;
@property (nonatomic) NSUInteger messagesCount;
@property (nonatomic) NSUInteger unreadMessagesCount;
@property (nonatomic) ATLMSettingsHeaderView *headerView;
@property (nonatomic) NSUInteger averageSend;

@end

@implementation ATLMSettingsViewController

NSString *const ATLMSettingsViewControllerTitle = @"Settings";
NSString *const ATLMSettingsTableViewAccessibilityIdentifier = @"Settings Table View";
NSString *const ATLMSettingsHeaderAccessibilityLabel = @"Settings Header";

NSString *const ATLMPushNotificationSettingSwitch = @"Push Notification Setting Switch";
NSString *const ATLMLocalNotificationSettingSwitch = @"Local Notification Setting Switch";
NSString *const ATLMDebugModeSettingSwitch = @"Debug Mode Setting Switch";

static NSString *const ATLMDefaultCellIdentifier = @"defaultTableViewCell";
static NSString *const ATLMCenterTextCellIdentifier = @"centerContentTableViewCell";

static NSString *const ATLMConnected = @"Connected";
static NSString *const ATLMDisconnected = @"Disconnected";
static NSString *const ATLMLostConnection = @"Lost Connection";
static NSString *const ATLMConnecting = @"Connecting";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = ATLMSettingsViewControllerTitle;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchConversationStatistics];
    
    [self.tableView registerClass:[ATLMStyleValue1TableViewCell class] forCellReuseIdentifier:ATLMDefaultCellIdentifier];
    [self.tableView registerClass:[ATLMCenterTextTableViewCell class] forCellReuseIdentifier:ATLMCenterTextCellIdentifier];
    
    // Left navigation item
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(doneTapped:)];
    doneButton.accessibilityLabel = @"Done";
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.headerView = [ATLMSettingsHeaderView headerViewWithUser:self.applicationController.APIManager.authenticatedSession.user];
    self.headerView.frame = CGRectMake(0, 0, 320, 148);
    self.headerView.accessibilityLabel = ATLMSettingsHeaderAccessibilityLabel;
    if (self.applicationController.layerClient.isConnected){
        [self.headerView updateConnectedStateWithString:ATLMConnected];
    } else {
        [self.headerView updateConnectedStateWithString:ATLMDisconnected];
    }
    
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.sectionHeaderHeight = 48.0f;
    self.tableView.sectionFooterHeight = 0.0f;
    self.tableView.rowHeight = 44.0f;
    self.tableView.accessibilityIdentifier = ATLMSettingsTableViewAccessibilityIdentifier;
    
    [self addConnectionObservers];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ATLMSettingsTableSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch ((ATLMSettingsTableSection)section) {
        case ATLMSettingsTableSectionNotifications:
            return ATLMNotificationsTableRowCount;
            
        case ATLMSettingsTableSectionDebug:
            return ATLMDebugTableRowCount;
            
        case ATLMSettingsTableSectionStatistics:
            return ATLMStatisticsTableRowCount;
            
        case ATLMSettingsTableSectionLogout:
            return 1;
            
        case ATLMSettingsTableSectionCount:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((ATLMSettingsTableSection)indexPath.section) {
        case ATLMSettingsTableSectionNotifications: {
            UITableViewCell *cell = [self defaultCellForIndexPath:indexPath];
            UISwitch *switchControl = [self switchForCell];
            switch ((ATLMNotificationsTableRow)indexPath.row) {
                case ATLMNotificationsTableRowSendPush:
                    cell.textLabel.text = @"Send Push Notifications";
                    switchControl.accessibilityLabel = ATLMPushNotificationSettingSwitch;
                    switchControl.on = self.applicationController.shouldSendPushText;
                    cell.accessoryView = switchControl;
                    break;
                    
                case ATLMNotificationsTableRowDisplayLocal:
                    cell.textLabel.text = @"Display Local Notifications";
                    switchControl.accessibilityLabel = ATLMLocalNotificationSettingSwitch;
                    switchControl.on = self.applicationController.shouldDisplayLocalNotifications;
                    cell.accessoryView = switchControl;
                    break;
                    
                case ATLMNotificationsTableRowCount:
                    break;
            }
            return cell;
        }
            
        case ATLMSettingsTableSectionDebug: {
            UITableViewCell *cell = [self defaultCellForIndexPath:indexPath];
            switch ((ATLMDebugTableRow)indexPath.row) {
                case ATLMDebugTableRowMode: {
                    cell.textLabel.text = @"Debug Mode";
                    UISwitch *switchControl = [self switchForCell];
                    switchControl.accessibilityLabel = ATLMDebugModeSettingSwitch;
                    switchControl.on = self.applicationController.debugModeEnabled;
                    cell.accessoryView = switchControl;
                }
                    break;

                case ATLMDebugTableRowSyncInterval: {
                    cell.textLabel.text = @"Synchronization Interval";
                    UITextField *syncIntervalLabel = [[UITextField alloc] init];
                    syncIntervalLabel.delegate = self;
                    syncIntervalLabel.text = [NSString stringWithFormat:@"%@", [self.applicationController.layerClient valueForKeyPath:@"synchronizationManager.syncInterval"]];
                    [syncIntervalLabel sizeToFit];
                    cell.accessoryView = syncIntervalLabel;
                }
                    break;

                case ATLMDebugTableRowVersion:
                    cell.textLabel.text = [NSString stringWithFormat:@"Version: %@", [ATLMApplicationController versionString]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case ATLMDebugTableRowBuild:
                    cell.textLabel.text = [NSString stringWithFormat:@"Build: %@", [ATLMApplicationController buildInformationString]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case ATLMDebugTableRowHost:
                    cell.textLabel.text = [NSString stringWithFormat:@"Host: %@", [ATLMApplicationController layerServerHostname]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case ATLMDebugTableRowUserID:
                    cell.textLabel.text = [NSString stringWithFormat:@"User ID: %@", self.applicationController.layerClient.authenticatedUserID];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case ATLMDebugTableRowDeviceToken:
                    cell.textLabel.text = [NSString stringWithFormat:@"Device Token: %@", [self.applicationController.deviceToken description]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case ATLMDebugTableRowCount:
                    break;
            }
            return cell;
        }
            
        case ATLMSettingsTableSectionStatistics: {
            UITableViewCell *cell = [self defaultCellForIndexPath:indexPath];
            switch ((ATLMStatisticsTableRow)indexPath.row) {
                case ATLMStatisticsTableRowConversations:
                    cell.textLabel.text = [NSString stringWithFormat:@"Conversations:"];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.conversationsCount];
                    break;
                    
                case ATLMStatisticsTableRowMessages:
                    cell.textLabel.text = [NSString stringWithFormat:@"Messages:"];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.messagesCount];
                    break;
                    
                case ATLMStatisticsTableRowUnread:
                    cell.textLabel.text = [NSString stringWithFormat:@"Unread Messages:"];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.unreadMessagesCount];
                    break;
                    
                case ATLMStatisticsTableRowCount:
                    break;
            }
            return cell;
        }
        
        case ATLMSettingsTableSectionLogout: {
            ATLMCenterTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ATLMCenterTextCellIdentifier forIndexPath:indexPath];
            cell.centerTextLabel.text = @"Log Out";
            cell.centerTextLabel.textColor = ATLRedColor();
            return cell;
        }
            
        case ATLMSettingsTableSectionCount:
            return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch ((ATLMSettingsTableSection)section) {
        case ATLMSettingsTableSectionNotifications:
            return @"Notifications";

        case ATLMSettingsTableSectionDebug:
            return @"Debug";

        case ATLMSettingsTableSectionStatistics:
            return @"Statistics";

        case ATLMSettingsTableSectionLogout:
        case ATLMSettingsTableSectionCount:
            return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == ATLMSettingsTableSectionCount) {
        //TODO - Add Atlas Footer
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == ATLMSettingsTableSectionLogout) {
        return 100;
    }
    return 0;
}

#pragma mark - Cell Configuration

- (UITableViewCell *)defaultCellForIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ATLMDefaultCellIdentifier forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
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
    switch ((ATLMSettingsTableSection)indexPath.section) {
        case ATLMSettingsTableSectionDebug:
            switch ((ATLMDebugTableRow)indexPath.row) {
                case ATLMDebugTableRowVersion:
                    [self showAlertViewForDebuggingWithTitle:@"Version" message:[ATLMApplicationController versionString]];
                    break;
                    
                case ATLMDebugTableRowBuild:
                    [self showAlertViewForDebuggingWithTitle:@"Build" message:[ATLMApplicationController buildInformationString]];
                    break;
                    
                case ATLMDebugTableRowHost:
                    [self showAlertViewForDebuggingWithTitle:@"Host" message:[ATLMApplicationController layerServerHostname]];
                    break;
                    
                case ATLMDebugTableRowUserID:
                    [self showAlertViewForDebuggingWithTitle:@"User ID" message:self.applicationController.layerClient.authenticatedUserID];
                    break;
                    
                case ATLMDebugTableRowDeviceToken:
                    if (self.applicationController.deviceToken) {
                        [self showAlertViewForDebuggingWithTitle:@"Device Token" message:[self.applicationController.deviceToken description]];
                    }
                    break;
                    
                case ATLMDebugTableRowMode:
                case ATLMDebugTableRowSyncInterval:
                case ATLMDebugTableRowCount:
                    break;
            }
            break;
        
        case ATLMSettingsTableSectionLogout:
            [self logOut];
            break;
            
        case ATLMSettingsTableSectionNotifications:
        case ATLMSettingsTableSectionStatistics:
        case ATLMSettingsTableSectionCount:
            break;
    }
}

#pragma mark - Actions

- (void)switchSwitched:(UISwitch *)switchControl
{
    CGPoint switchControlCenter = [self.tableView convertPoint:switchControl.center fromView:switchControl.superview];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:switchControlCenter];
    switch ((ATLMSettingsTableSection)indexPath.section) {
        case ATLMSettingsTableSectionNotifications:
            switch ((ATLMNotificationsTableRow)indexPath.row) {
                case ATLMNotificationsTableRowSendPush:
                    self.applicationController.shouldSendPushText = switchControl.on;
                    break;
                    
                case ATLMNotificationsTableRowDisplayLocal:
                    self.applicationController.shouldDisplayLocalNotifications = switchControl.on;
                    break;
                    
                case ATLMNotificationsTableRowCount:
                    break;
            }
            break;
            
        case ATLMSettingsTableSectionDebug:
            switch ((ATLMDebugTableRow)indexPath.row) {
                case ATLMDebugTableRowMode:
                    self.applicationController.debugModeEnabled = switchControl.on;
                    break;
                    
                case ATLMDebugTableRowSyncInterval:
                case ATLMDebugTableRowVersion:
                case ATLMDebugTableRowBuild:
                case ATLMDebugTableRowHost:
                case ATLMDebugTableRowUserID:
                case ATLMDebugTableRowDeviceToken:
                case ATLMDebugTableRowCount:
                    break;
            }
            break;
            
        case ATLMSettingsTableSectionStatistics:
        case ATLMSettingsTableSectionLogout:
        case ATLMSettingsTableSectionCount:
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
    [self.headerView updateConnectedStateWithString:ATLMConnected];
}

- (void)layerDidDisconnect:(NSNotification *)notification
{
    [self.headerView updateConnectedStateWithString:ATLMDisconnected];
}

- (void)layerIsConnecting:(NSNotification *)notification
{
    [self.headerView updateConnectedStateWithString:ATLMConnecting];
}

- (void)layerDidLoseConnection:(NSNotification *)notification
{
    [self.headerView updateConnectedStateWithString:ATLMLostConnection];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.applicationController.layerClient setValue:@(textField.text.intValue) forKeyPath:@"synchronizationManager.syncInterval"];
    return YES;
}

@end
