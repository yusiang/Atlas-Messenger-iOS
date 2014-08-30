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

@interface LSUIConversationListViewController () <LYRUIConversationListViewControllerDelegate, LYRUIParticipantPickerControllerDelegate>

@end

@implementation LSUIConversationListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    
    // Left navigation item
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logout"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(logoutTapped)];
    logoutButton.accessibilityLabel = @"logout";
    [self.navigationItem setLeftBarButtonItem:logoutButton];
    
    // Right navigation item
    UIBarButtonItem *newConversationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"compose"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(newConversationTapped)];
    newConversationButton.accessibilityLabel = @"New";
    [self.navigationItem setRightBarButtonItem:newConversationButton];
}

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
    //Dont Care
}

- (NSString *)conversationLabelForParticipants:(NSSet *)participantIDs inConversationListViewController:(LYRUIConversationListViewController *)conversationListViewController
{
    NSSet *participants = [self.applicationController.persistenceManager participantsForIdentifiers:participantIDs];
    NSString *conversationLabel = @"";
    for (LSUser *user in participants) {
        conversationLabel = [NSString stringWithFormat:@"%@ %@", conversationLabel, user.fullName];
    }
    return conversationLabel;
}

#pragma mark
#pragma mark Bar Button Functionality Methods

- (void)logoutTapped
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

- (void)newConversationTapped
{
    NSSet *participants = [self.applicationController.persistenceManager persistedUsersWithError:nil];
    LYRUIParticipantPickerController *controller = [LYRUIParticipantPickerController participantPickerWithParticipants:participants];
    controller.participantPickerDelegate = self;
    [self presentViewController:controller animated:TRUE completion:nil];
}

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
