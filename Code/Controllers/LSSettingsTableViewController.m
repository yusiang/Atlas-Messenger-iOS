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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSDefaultCellIdentifier];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    LSSwitch *radioSwitch = [[LSSwitch alloc] init];
    radioSwitch.indexPath = indexPath;
    [radioSwitch addTarget:self action:@selector(switchSwitched:) forControlEvents:UIControlEventTouchUpInside];
    
    switch ((LSSettingsTableSection)indexPath.section) {
            
        case LSSettingsTableSectionNotifications: {
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
        }
            break;
            
        case LSSettingsTableSectionDebug: {
            switch ((LSDebugTableRow)indexPath.row) {
                case LSDebugTableRowMode:
                    cell.textLabel.text = @"Debug Mode ";
                    radioSwitch.on = self.applicationController.debugModeEnabled;
                    cell.accessoryView = radioSwitch;
                    break;
                    
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
                    cell.textLabel.text = [NSString stringWithFormat:@"UserID: %@", self.applicationController.layerClient.authenticatedUserID];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case LSDebugTableRowDeviceToken:
                    cell.textLabel.text = [NSString stringWithFormat:@"Device Token: %@", [self.applicationController.deviceToken description]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case LSDebugTableRowCount:
                    break;
            }
        }
            break;
            
        case LSSettingsTableSectionStatistics: {
            switch ((LSStatisticsTableRow)indexPath.row) {
                case LSStatisticsTableRowConversations: {
                    cell.textLabel.text = [NSString stringWithFormat:@"Conversations:"];
                    UILabel *conversationsLabel = [[UILabel alloc] init];
                    conversationsLabel.text = [[self.conversationStatistics objectForKey:LSConversationCountKey]stringValue];
                    conversationsLabel.font = cell.textLabel.font;
                    [conversationsLabel sizeToFit];
                    cell.accessoryView = conversationsLabel;
                }
                    break;
                    
                case LSStatisticsTableRowMessages: {
                    cell.textLabel.text = [NSString stringWithFormat:@"Messages:"];
                    UILabel *messagesLabel = [[UILabel alloc] init];
                    messagesLabel.text = [[self.conversationStatistics objectForKey:LSMessageCountKey]stringValue];
                    messagesLabel.font = cell.textLabel.font;
                    [messagesLabel sizeToFit];
                    cell.accessoryView = messagesLabel;
                }
                    break;
                    
                case LSStatisticsTableRowUnread: {
                    cell.textLabel.text = [NSString stringWithFormat:@"Unread Messages:"];
                    UILabel *unreadMessagesLabel = [[UILabel alloc] init];
                    unreadMessagesLabel.text = [[self.conversationStatistics objectForKey:LSUnreadMessageCountKey]stringValue];
                    unreadMessagesLabel.font = cell.textLabel.font;
                    [unreadMessagesLabel sizeToFit];
                    cell.accessoryView = unreadMessagesLabel;
                }
                    break;
                    
                case LSStatisticsTableRowCount:
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
            
        case LSSettingsTableSectionCount:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((LSSettingsTableSection)indexPath.section) {
        case LSSettingsTableSectionDebug:
            switch ((LSDebugTableRow)indexPath.row) {
                case LSDebugTableRowVersion:
                     [self settingsAlertWithString:[LSApplicationController versionString]];
                    break;
                    
                case LSDebugTableRowBuild:
                     [self settingsAlertWithString:[LSApplicationController buildInformationString]];
                    break;
                    
                case LSDebugTableRowHost:
                     [self settingsAlertWithString:[LSApplicationController layerServerHostname]];
                    break;
                    
                case LSDebugTableRowUserID:
                     [self settingsAlertWithString:self.applicationController.layerClient.authenticatedUserID];
                    break;
                    
                case LSDebugTableRowDeviceToken:
                     [self settingsAlertWithString:[self.applicationController.deviceToken description]];
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
            return @"NOTIFICATIONS";
            
        case LSSettingsTableSectionDebug:
            return  @"DEBUG";
            
        case LSSettingsTableSectionStatistics:
            return @"STATISTICS";
            
        case LSSettingsTableSectionLogout:
        case LSSettingsTableSectionCount:
            return nil;
    }
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
