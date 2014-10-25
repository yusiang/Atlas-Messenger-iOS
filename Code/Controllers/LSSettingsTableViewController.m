//
//  LSSettingsViewControllerTableViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 10/20/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSSettingsTableViewController.h"
#import "LSSwitch.h"
#import "LSDetailHeaderView.h"
#import "LYRUIConstants.h"
#import "SVProgressHUD.h"
#import "LSSettingsHeaderView.h"
#import "LSCenterTextTableViewCell.h"

@interface LSSettingsTableViewController ()

@property (nonatomic, strong) NSDictionary *conversationStatistics;
@property (nonatomic) LSSettingsHeaderView *headerView;

@end

@implementation LSSettingsTableViewController

NSString *const LSDefaultCell = @"defaultTableViewCell";
NSString *const LSCenterTextCell = @"centerContentTableViewCell";

NSString *const LSConversationCount = @"LSConversationCount";
NSString *const LSMessageCount = @"LSMessageCount";
NSString *const LSUnreadMessageCount = @"LSUnreadMessageCount";

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
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:LSDefaultCell];
    [self.tableView registerClass:[LSCenterTextTableViewCell class] forCellReuseIdentifier:LSCenterTextCell];
    
    // Left navigation item
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 3;
            break;
        case 3:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSDefaultCell];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    LSSwitch *radioSwitch = [[LSSwitch alloc] init];
    radioSwitch.indexPath = indexPath;
    [radioSwitch addTarget:self action:@selector(switchSwitched:) forControlEvents:UIControlEventTouchUpInside];
    
    switch (indexPath.section) {
            
        case 0: {
            // Push Configuration
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Send Silent Notifications";
                    radioSwitch.on = self.applicationController.shouldSendPushText;
                    cell.accessoryView = radioSwitch;
                    break;
                case 1:
                    cell.textLabel.text = @"Send Push Notification Sound";
                    radioSwitch.on = self.applicationController.shouldSendPushSound;
                    cell.accessoryView = radioSwitch;
                    break;
                case 2:
                    cell.textLabel.text = @"Display Local Notifications";
                    radioSwitch.on = self.applicationController.shouldDisplayLocalNotifications;
                    cell.accessoryView = radioSwitch;
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 1: {
             // Layer Stats Stats
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = [NSString stringWithFormat:@"Conversations:"];
                    UILabel *conversationsLabel = [[UILabel alloc] init];
                    conversationsLabel.text = [[self.conversationStatistics objectForKey:LSConversationCount]stringValue];
                    conversationsLabel.font = cell.textLabel.font;
                    [conversationsLabel sizeToFit];
                    cell.accessoryView = conversationsLabel;
                }
                    break;
                case 1: {
                    cell.textLabel.text = [NSString stringWithFormat:@"Messages:"];
                    UILabel *messagesLabel = [[UILabel alloc] init];
                    messagesLabel.text = [[self.conversationStatistics objectForKey:LSMessageCount]stringValue];
                    messagesLabel.font = cell.textLabel.font;
                    [messagesLabel sizeToFit];
                    cell.accessoryView = messagesLabel;
                }
                    break;
                case 2: {
                    cell.textLabel.text = [NSString stringWithFormat:@"Unread Messages:"];
                    UILabel *unreadMessagesLabel = [[UILabel alloc] init];
                    unreadMessagesLabel.text = [[self.conversationStatistics objectForKey:LSUnreadMessageCount]stringValue];
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
            
        case 2: {
            // // Debug Mode
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Debug Mode ";
                    radioSwitch.on = self.applicationController.debugModeEnabled;
                    cell.accessoryView = radioSwitch;
                    break;
                case 1:
                    cell.textLabel.text = @"Copy Device Token";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                case 2:
                    cell.textLabel.text = @"Reload Contacts";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                default:
                    break;
            }
        }
            break;
        
        case 3: {
            LSCenterTextTableViewCell *centerCell = [self.tableView dequeueReusableCellWithIdentifier:LSCenterTextCell];
            [centerCell setCenterText:@"Log Out"];
            centerCell.centerTextLabel.textColor = LSRedColor();
            return centerCell;
        }
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 2:
            switch (indexPath.row) {
                case 1:
                    [self copyDeviceToken];
                    break;
                case 2:
                    [self reloadContacts];
                    break;
                default:
                    break;
            }
            break;
        
        case 3:
            [self logOut];
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 48;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [LSDetailHeaderView initWithTitle:@"NOTIFICATIONS"];
            break;
        case 1:
            return [LSDetailHeaderView initWithTitle:@"STATISTICS"];
            break;
        case 2:
            return [LSDetailHeaderView initWithTitle:@"DEBUG"];
            break;
        default:
            break;
    }
    return nil;
}


- (NSDictionary *)fetchConversationStatistics
{
    NSUInteger conversationCount = 0;
    NSUInteger messageCount = 0;
    NSUInteger unreadMessageCount = 0;
    
    NSArray *conversations = [[self.applicationController.layerClient conversationsForIdentifiers:nil] allObjects];
    for (LYRConversation *conversation in conversations) {
        conversationCount++;
        NSArray *messages = [[self.applicationController.layerClient  messagesForConversation:conversation] array];
        for (LYRMessage *message in messages) {
            messageCount++;
            if ([[message.recipientStatusByUserID objectForKey:self.applicationController.layerClient.authenticatedUserID] integerValue] == 1){
                unreadMessageCount++;
            }
        }
    }
    NSDictionary *conversationStatistics = @{LSConversationCount : [NSNumber numberWithInteger:conversationCount],
                                             LSMessageCount : [NSNumber numberWithInteger:messageCount],
                                             LSUnreadMessageCount : [NSNumber numberWithInteger:unreadMessageCount]};
    return conversationStatistics;
}

- (void)switchSwitched:(UIControl *)sender
{
    LSSwitch *radioButton = (LSSwitch *)sender;
    NSIndexPath *indexPath = [(LSSwitch *)sender indexPath];
    switch (indexPath.section) {
        case 0:
            // Push Configuration
            switch (indexPath.row) {
                case 0:
                    self.applicationController.shouldSendPushText = radioButton.on;
                    break;
                case 1:
                    self.applicationController.shouldSendPushSound = radioButton.on;
                    break;
                case 2:
                    self.applicationController.shouldDisplayLocalNotifications = radioButton.on;
                    break;
                default:
                    break;
            }
            break;
            
        case 2:
            // // Debug Mode
            switch (indexPath.row) {
                case 0:
                    self.applicationController.debugModeEnabled = radioButton.on;
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

- (void)doneTapped:(UIControl *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)copyDeviceToken
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.applicationController.deviceToken) {
        pasteboard.string = [self.applicationController.deviceToken description];
        [SVProgressHUD showSuccessWithStatus:@"Copied"];
    } else {
        [SVProgressHUD showErrorWithStatus:@"No Device Token Available"];
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

@end
