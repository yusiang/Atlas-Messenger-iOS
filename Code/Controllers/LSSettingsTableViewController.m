//
//  LSSettingsViewControllerTableViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 10/20/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSSettingsTableViewController.h"
#import "LSSwitch.h"

@interface LSSettingsTableViewController ()

@property (nonatomic, strong) NSDictionary *conversationStatistics;

@end

@implementation LSSettingsTableViewController

NSString *const LSConversationCount = @"LSConversationCount";
NSString *const LSMessageCount = @"LSMessageCount";
NSString *const LSUnreadMessageCount = @"LSUnreadMessageCount";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    // Left navigation item
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelTapped:)];
    menuButton.accessibilityLabel = @"logout";
    [self.navigationItem setLeftBarButtonItem:menuButton];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    LSSwitch *radioSwitch = [[LSSwitch alloc] init];
    radioSwitch.indexPath = indexPath;
    [radioSwitch addTarget:self action:@selector(switchSwitched:) forControlEvents:UIControlEventTouchUpInside];
    
    switch (indexPath.section) {
            
        case 0: {
            // Push Configuration
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Silent Notifications";
                    radioSwitch.on = self.applicationController.shouldSendPushText;
                    cell.accessoryView = radioSwitch;
                    break;
                case 1:
                    cell.textLabel.text = @"Push Notification Sound";
                    radioSwitch.on = self.applicationController.shouldSendPushSound;
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
                    NSNumber *conversations = [self.conversationStatistics objectForKey:LSConversationCount];
                    cell.textLabel.text = [NSString stringWithFormat:@"Conversations: %@", conversations];
                }
                    break;
                case 1:
                {
                    NSNumber *messages = [self.conversationStatistics objectForKey:LSMessageCount];
                    cell.textLabel.text = [NSString stringWithFormat:@"Messages: %@", messages];
                }
                    break;
                case 2:
                {
                    NSNumber *unreadMessages = [self.conversationStatistics objectForKey:LSUnreadMessageCount];
                    cell.textLabel.text = [NSString stringWithFormat:@"Unread Messages: %@", unreadMessages];
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
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    return cell;
}

- (NSDictionary *)conversationStatistics
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

- (void)cancelTapped:(UIControl *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
