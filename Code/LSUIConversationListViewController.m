//
//  LSConversationListViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSUIConversationListViewController.h"
#import "LYRUIParticipantPickerController.h"
#import "LSConversationViewController.h"
#import "SVProgressHUD.h"
#import "LSConversationViewController.h"
#import "LSUser.h"
#import "LSUIParticipantPickerDataSource.h"

@interface LSUIConversationListViewController () <LYRUIConversationListViewControllerDelegate, LYRUIParticipantPickerControllerDelegate>

@property (nonatomic, strong) LSUIParticipantPickerDataSource *participantPickerDataSource;

@end

@implementation LSUIConversationListViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    
    self.participantPickerDataSource = [LSUIParticipantPickerDataSource participantPickerDataSourceWithPersistenceManager:self.applicationController.persistenceManager];
    
    // Left navigation item
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(logoutButtonTapped)];
    logoutButton.accessibilityLabel = @"logout";
    [self.navigationItem setLeftBarButtonItem:logoutButton];
    
    // Right navigation item
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"compose"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(composeButtonTapped)];
    composeButton.accessibilityLabel = @"New";
    [self.navigationItem setRightBarButtonItem:composeButton];
}

#pragma mark LYRUIConversationListViewControllerDelegate methods

- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation
{
    LSConversationViewController *viewController = [LSConversationViewController new];
    viewController.conversation = conversation;
    viewController.layerClient = self.applicationController.layerClient;
    viewController.persistanceManager = self.applicationController.persistenceManager;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)conversationListViewControllerDidCancel:(LYRUIConversationListViewController *)conversationListViewController
{
    //Dont Care - Not even sure we need this
}

- (NSString *)conversationLabelForParticipants:(NSSet *)participantIDs inConversationListViewController:(LYRUIConversationListViewController *)conversationListViewController
{
    NSMutableSet *participantIdentifiers = [NSMutableSet setWithSet:participantIDs];
    
    if ([participantIdentifiers containsObject:self.applicationController.layerClient.authenticatedUserID]) {
        [participantIdentifiers removeObject:self.applicationController.layerClient.authenticatedUserID];
    }
    
    if (!participantIdentifiers.count > 0) return @"";
    
    NSSet *participants = [self.applicationController.persistenceManager participantsForIdentifiers:participantIdentifiers];
    
    if (!participants.count > 0) return @"";
    
    LSUser *firstUser = [[participants allObjects] objectAtIndex:0];
    NSString *conversationLabel = firstUser.fullName;
    for (int i = 1; i < [[participants allObjects] count]; i++) {
        LSUser *user = [[participants allObjects] objectAtIndex:i];
        conversationLabel = [NSString stringWithFormat:@"%@, %@", conversationLabel, user.fullName];
    }
    return conversationLabel;
}

#pragma mark - Bar Button Functionality Methods

- (void)logoutButtonTapped
{
    [SVProgressHUD show];
    [self.applicationController.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [self.applicationController.APIManager deauthenticate];
            NSLog(@"Deauthenticated...");
        } else {
            LSAlertWithError(error);
        }
        [SVProgressHUD dismiss];
    }];
}

- (void)composeButtonTapped
{
    LYRUIParticipantPickerController *controller = [LYRUIParticipantPickerController participantPickerWithParticipants:self.participantPickerDataSource
                                                                                                              sortType:LYRUIParticipantPickerControllerSortTypeFirst];
    controller.participantPickerDelegate = self;
    controller.allowsMultipleSelection = YES;
    [self presentViewController:controller animated:TRUE completion:nil];
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
            
            LSConversationViewController *controller = [LSConversationViewController new];
            
            NSSet *participantIdentifiers = [participants valueForKey:@"participantIdentifier"];
            LYRConversation *conversation = [[self.applicationController.layerClient conversationsForParticipants:participantIdentifiers] anyObject];
            
            if (!conversation) {
                conversation = [LYRConversation conversationWithParticipants:participantIdentifiers];
            }
            
            controller.conversation = conversation;
            controller.layerClient = self.applicationController.layerClient;
            controller.persistanceManager = self.applicationController.persistenceManager;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }];
}
@end
