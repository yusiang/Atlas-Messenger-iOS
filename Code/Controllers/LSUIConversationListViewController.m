//
//  LSConversationListViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSUIConversationListViewController.h"
#import "LYRUIParticipantPickerController.h"
#import "SVProgressHUD.h"
#import "LSUser.h"
#import "LSUIParticipantPickerDataSource.h"
#import "LSUIConversationViewController.h"
#import "LSSettingsTableViewController.h"

@interface LSUIConversationListViewController () <LYRUIConversationListViewControllerDelegate, LYRUIConversationListViewControllerDataSource, LYRUIParticipantPickerControllerDelegate, LSSettingsTableViewControllerDelegate, UIActionSheetDelegate>

@property (nonatomic) LSUIParticipantPickerDataSource *participantPickerDataSource;

@end

@implementation LSUIConversationListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.delegate = self;
    self.dataSource = self;
    
    self.participantPickerDataSource = [LSUIParticipantPickerDataSource participantPickerDataSourceWithPersistenceManager:self.applicationController.persistenceManager];
    
    // Left navigation item
    if (self.shouldDisplaySettingsItem) {
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(settingsButtonTapped)];
        settingsButton.accessibilityLabel = @"Settings";
        [self.navigationItem setLeftBarButtonItem:settingsButton];
    }

    // Right navigation item
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                   target:self
                                                                                   action:@selector(composeButtonTapped)];
    composeButton.accessibilityLabel = @"New";
    [self.navigationItem setRightBarButtonItem:composeButton];
}

#pragma mark LYRUIConversationListViewControllerDelegate methods

- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation
{
    [self presentControllerWithConversation:conversation];
}

- (NSString *)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController labelForConversation:(LYRConversation *)conversation
{
    NSMutableSet *participantIdentifiers = [NSMutableSet setWithSet:conversation.participants];
    
    if ([participantIdentifiers containsObject:self.applicationController.layerClient.authenticatedUserID]) {
        [participantIdentifiers removeObject:self.applicationController.layerClient.authenticatedUserID];
    }
    
    if (!participantIdentifiers.count > 0) return @"Personal Conversation";
    
    NSMutableSet *participants = [[self.applicationController.persistenceManager participantsForIdentifiers:participantIdentifiers] mutableCopy];
    
    if (!participants.count > 0) return @"No Matching Participants";
    
    LSUser *firstUser;
    if (![conversation.lastMessage.sentByUserID isEqualToString:self.layerClient.authenticatedUserID]){
        if (conversation.lastMessage) {
            NSSet *lastMessageSender = [self.applicationController.persistenceManager participantsForIdentifiers:[NSSet setWithObject:conversation.lastMessage.sentByUserID]];
            if ([lastMessageSender allObjects].count > 0) {
                firstUser = [[lastMessageSender allObjects] firstObject];
                [participants removeObject:firstUser];
            }
        }
    } else {
        firstUser = [[participants allObjects] objectAtIndex:0];
    }
    NSString *conversationLabel = firstUser.fullName;
    for (int i = 1; i < [[participants allObjects] count]; i++) {
        LSUser *user = [[participants allObjects] objectAtIndex:i];
        conversationLabel = [NSString stringWithFormat:@"%@, %@", conversationLabel, user.fullName];
    }
    return conversationLabel;
}

- (UIImage *)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController imageForConversation:(LYRConversation *)conversation
{
    return [UIImage imageNamed:@"testImage"];
}

#pragma mark - LYRUIParticipantTableViewControllerDelegate methods

- (void)participantSelectionViewControllerDidCancel:(LYRUIParticipantPickerController *)participantSelectionViewController
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)participantSelectionViewController:(LYRUIParticipantPickerController *)participantSelectionViewController didSelectParticipants:(NSSet *)participants
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (participants.count > 0) {
            NSSet *participantIdentifiers = [participants valueForKey:@"participantIdentifier"];
            LYRConversation *conversation = [[self.applicationController.layerClient conversationsForParticipants:participantIdentifiers] anyObject];
            if (!conversation) {
                conversation = [LYRConversation conversationWithParticipants:participantIdentifiers];
            }
            [self presentControllerWithConversation:conversation];
        }
    }];
}

#pragma mark Selected Conversation Methods

- (void)presentControllerWithConversation:(LYRConversation *)conversation
{
    LSUIConversationViewController *viewController = [LSUIConversationViewController conversationViewControllerWithConversation:conversation
                                                                                                                    layerClient:self.applicationController.layerClient];
    viewController.applicationContoller = self.applicationController;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Bar Button Functionality Methods

- (void)settingsButtonTapped
{
    LSSettingsTableViewController *settingsTableViewController = [[LSSettingsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    settingsTableViewController.applicationController = self.applicationController;
    settingsTableViewController.settingsDelegate = self;
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:settingsTableViewController];
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

- (void)composeButtonTapped
{
    LYRUIParticipantPickerController *controller = [LYRUIParticipantPickerController participantPickerWithDataSource:self.participantPickerDataSource
                                                                                                              sortType:LYRUIParticipantPickerControllerSortTypeFirst];
    controller.participantPickerDelegate = self;
    controller.allowsMultipleSelection = YES;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Push Notification Selection Method

- (void)selectConversation:(LYRConversation *)conversation
{
    [self.navigationController popToRootViewControllerAnimated:TRUE];
    if (conversation) {
        [self presentControllerWithConversation:conversation];
    }
}

#pragma mark - Settings View Controller Delegate

- (void)logoutTappedInSettingsTableViewController:(LSSettingsTableViewController *)settingsTableViewController
{
    [SVProgressHUD show];
    if (self.applicationController.layerClient.isConnected) {
        [self.applicationController.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                [self.applicationController.APIManager deauthenticate];
            }
            [SVProgressHUD dismiss];
        }];
    } else {
        [self.applicationController.APIManager deauthenticate];
        [SVProgressHUD dismiss];
    }
}

@end
