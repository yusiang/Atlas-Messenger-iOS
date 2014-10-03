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
#import "LSVersionView.h"

@interface LSUIConversationListViewController () <LYRUIConversationListViewControllerDelegate, LYRUIConversationListViewControllerDataSource, LYRUIParticipantPickerControllerDelegate, UIActionSheetDelegate>

@property (nonatomic) LSUIParticipantPickerDataSource *participantPickerDataSource;
@property (nonatomic) LSVersionView *versionView;

@end

@implementation LSUIConversationListViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.delegate = self;
    self.dataSource = self;
    
    self.participantPickerDataSource = [LSUIParticipantPickerDataSource participantPickerDataSourceWithPersistenceManager:self.applicationController.persistenceManager];
    
    // Left navigation item
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(meunButtonTapped)];
    menuButton.accessibilityLabel = @"logout";
    [self.navigationItem setLeftBarButtonItem:menuButton];
    
    // Right navigation item
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                   target:self
                                                                                   action:@selector(composeButtonTapped)];
    composeButton.accessibilityLabel = @"New";
    [self.navigationItem setRightBarButtonItem:composeButton];
    
    self.versionView = [[LSVersionView alloc] initWithFrame:CGRectZero];
    self.versionView.versionLabel.text = [LSApplicationController versionString];
    self.versionView.buildLabel.text = [LSApplicationController buildInformationString];
    self.versionView.hostLabel.text = [LSApplicationController layerServerHostname];
    self.versionView.userLabel.text = [NSString stringWithFormat:@"User ID: %@", self.applicationController.layerClient.authenticatedUserID];
    
    NSUUID *UUID = self.applicationController.deviceToken ? [[NSUUID alloc] initWithUUIDBytes:[self.applicationController.deviceToken bytes]] : nil;
    self.versionView.deviceLabel.text = [NSString stringWithFormat:@"Device Token: %@", [UUID UUIDString]];
    [self.versionView sizeToFit];
    [self.tableView addSubview:self.versionView];
    
    self.versionView.frame = CGRectMake((int)(self.tableView.frame.size.width / 2.0 - self.versionView.frame.size.width / 2.0),
                                        -(self.versionView.frame.size.height + 15),
                                        self.versionView.frame.size.width,
                                        self.versionView.frame.size.height);
}

#pragma mark LYRUIConversationListViewControllerDelegate methods

- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation
{
    [self presentControllerWithConversation:conversation];
}

- (NSString *)conversationLabelForParticipants:(NSSet *)participantIDs inConversationListViewController:(LYRUIConversationListViewController *)conversationListViewController
{
    NSMutableSet *participantIdentifiers = [NSMutableSet setWithSet:participantIDs];
    
    if ([participantIdentifiers containsObject:self.applicationController.layerClient.authenticatedUserID]) {
        [participantIdentifiers removeObject:self.applicationController.layerClient.authenticatedUserID];
    }
    
    if (!participantIdentifiers.count > 0) return @"Personal Conversation";
    
    NSSet *participants = [self.applicationController.persistenceManager participantsForIdentifiers:participantIdentifiers];
    
    if (!participants.count > 0) return @"No Matching Participants";
    
    LSUser *firstUser = [[participants allObjects] objectAtIndex:0];
    NSString *conversationLabel = firstUser.fullName;
    for (int i = 1; i < [[participants allObjects] count]; i++) {
        LSUser *user = [[participants allObjects] objectAtIndex:i];
        conversationLabel = [NSString stringWithFormat:@"%@, %@", conversationLabel, user.fullName];
    }
    return conversationLabel;
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

- (void)presentControllerWithConversation:(LYRConversation *)conversation
{
    LSUIConversationViewController *viewController = [LSUIConversationViewController conversationViewControllerWithConversation:conversation
                                                                                                                    layerClient:self.applicationController.layerClient];
    viewController.applicationContoller = self.applicationController;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Bar Button Functionality Methods

- (void)meunButtonTapped
{
    NSString *user = self.applicationController.APIManager.authenticatedSession.user.fullName;
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:[NSString stringWithFormat:@"Logout - %@", user], @"Reload Contacts", @"Copy Device Token", nil];
    
    [actionSheet showInView:self.view];
}

- (void)composeButtonTapped
{
    LYRUIParticipantPickerController *controller = [LYRUIParticipantPickerController participantPickerWithParticipants:self.participantPickerDataSource
                                                                                                              sortType:LYRUIParticipantPickerControllerSortTypeFirst];
    controller.participantPickerDelegate = self;
    controller.allowsMultipleSelection = YES;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self logout];
            break;
            
        case 1:
            [SVProgressHUD showWithStatus:@"Loading Contacts"];
            [self.applicationController.APIManager loadContactsWithCompletion:^(NSSet *contacts, NSError *error) {
                [SVProgressHUD showSuccessWithStatus:@"Contacts Loaded"];
            }];
            break;
            
        case 2: {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            if (self.applicationController.deviceToken) {
                pasteboard.string = [self.applicationController.deviceToken description];
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

- (void)logout
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


@end
