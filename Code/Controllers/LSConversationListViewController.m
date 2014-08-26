//
//  LSConversationListVC.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSConversationListViewController.h"
#import "LSNotificationObserver.h"
#import "LSVersionView.h"
#import "LSApplicationController.h"
#import "LSConversationCellPresenter.h"
#import "LSConversationViewController.h"
#import "SVProgressHUD.h"
#import "LSContactsSelectionViewController.h"
#import "LSUIConstants.h"
#import "LSContactListViewController.h"

@interface LSConversationListViewController () <LSNotificationObserverDelegate, LSContactListViewControllerDelegate>

@property (nonatomic, strong) NSArray *conversations;
@property (nonatomic, strong) NSArray *filteredConversations;
@property (nonatomic, strong) NSPredicate *filterPredicate;
@property (nonatomic, strong) LSNotificationObserver *notificationObserver;
@property (nonatomic, strong) LSVersionView *versionView;

@end

@implementation LSConversationListViewController

static NSString *const LSConversationCellID = @"conversationCellIdentifier";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Make sure the applicationController object is not nil
    NSAssert(self.applicationController, @"`self.applicationController` cannot be nil");
    
    // Titles for the VC and accessiblitiy
    self.title = @"Conversations";
    self.accessibilityLabel = @"Conversation List";
    
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
    
    // Adds a version view to the top tableView behind the Navigation bar
    [self addVersionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Load Layer Conversation List
    [self fetchLayerConversations];
    
    // Adds thev view controller as the LSNotification Observer so that it can listen to changes from Layer
    self.notificationObserver = [[LSNotificationObserver alloc] initWithClient:self.applicationController.layerClient conversations:self.conversations];
    self.notificationObserver.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Removes self as observer
    self.notificationObserver = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)fetchLayerConversations
{
    // Make sure the Layer Client object is not nil
    NSAssert(self.applicationController.layerClient, @"Layer Client should not be `nil`.");

    // Fetch all conversations from LayerKit
    NSSet *conversations = (NSSet *)[self.applicationController.layerClient conversationsForIdentifiers:nil];
    
    // Sort the messages according to the Last Message sent at date
    self.conversations = [[conversations allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastMessage.sentAt" ascending:NO]]];
    
    // Set the array we will use for searching
    self.filteredConversations = [conversations allObjects];
    
    // Tells super view to reload table view data
    [self reloadConversations];
}

- (NSArray *)currentDataArray
{
    if (self.searchActive) {
        return self.filteredConversations;
    }
    
    return self.conversations;
}

#pragma mark - LYRConversationListViewControllerDataSource

- (NSUInteger)numberOfConversationsInViewController:(LYRConversationListViewController *)conversationListViewController
{
    return [[self currentDataArray] count];
}

- (id<LYRConversationCellPresenter>)conversationListViewController:(LYRConversationListViewController *)conversationListViewController presenterForConversationAtIndex:(NSUInteger)index
{
    return [LSConversationCellPresenter presenterWithConversation:[[self currentDataArray] objectAtIndex:index] persistanceManager:self.applicationController.persistenceManager];
}

- (void)conversationListViewController:(LYRConversationListViewController *)conversationListViewController deleteConversationAtIndex:(NSUInteger)index
{
    NSError *error;
    BOOL success = [self.applicationController.layerClient deleteConversation:[[self currentDataArray] objectAtIndex:index] error:&error];
    if (success) {
        NSLog(@"Conversation Deleted!");
    } else {
        NSLog(@"Conversation Not Deleted with Error %@", error);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Failed"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)conversationListViewController:(LYRConversationListViewController *)conversationListViewController didSearchWithString:(NSString *)searchString completion:(void (^)())completion
{
    NSSet *allUsers = [self.applicationController.persistenceManager persistedUsersWithError:NULL];
    
    NSString *wildcard = [NSString stringWithFormat:@"*%@*", searchString];
    
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"(fullName like[cd] %@)", wildcard];
    NSSet *filteredUsers = [allUsers filteredSetUsingPredicate:filterPredicate];
    NSSet *filteredUserIDs = [filteredUsers valueForKey:@"userID"];
    
    NSMutableOrderedSet *filteredConversations = [NSMutableOrderedSet orderedSet];
    for (LYRConversation *conversation in self.conversations) {
        for (NSString *participantID in filteredUserIDs) {
            if ([conversation.participants containsObject:participantID]) {
                [filteredConversations addObject:conversation];
            }
        }
    }
    
    // do a filter of the search
    self.filteredConversations = [filteredConversations array];
    completion();
}

#pragma mark - LYRConversationListViewControllerDelegate methods

- (void)conversationListViewController:(LYRConversationListViewController *)conversationListViewcontroller didSelectConversationAtIndex:(NSUInteger)index
{
    LSConversationViewController *viewController = [LSConversationViewController new];
    viewController.conversation = [[self currentDataArray] objectAtIndex:index];
    viewController.layerClient = self.applicationController.layerClient;
    viewController.persistanceManager = self.applicationController.persistenceManager;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (CGFloat)conversationListViewController:(LYRConversationListViewController *)conversationListViewcontroller heightForConversationAtIndex:(NSUInteger)index
{
    return 80;
}

#pragma mark
#pragma mark Bar Button Functionality Methods

- (void)logoutTapped
{
    [SVProgressHUD show];
    [self.applicationController.APIManager deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        NSLog(@"Deauthenticated...");
    }];
}

- (void)newConversationTapped
{
    LSContactListViewController *contactsViewController = [LSContactListViewController new];
    contactsViewController.applicationController = self.applicationController;
    contactsViewController.selectionDelegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contactsViewController];
    navigationController.navigationBar.tintColor = LSBlueColor();
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - LSContactsSelectionViewControllerDelegate methods

- (void)contactsSelectionViewController:(LSContactsSelectionViewController *)contactsSelectionViewController didSelectContacts:(NSSet *)contacts
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (contacts.count > 0) {
            
            LSConversationViewController *controller = [LSConversationViewController new];
            
            NSSet *participants = [contacts valueForKey:@"userID"];
            LYRConversation *conversation = [[self.applicationController.layerClient conversationsForParticipants:participants] anyObject];
            
            if (!conversation) {
                conversation = [LYRConversation conversationWithParticipants:participants];
            }
            
            controller.conversation = conversation;
            controller.layerClient = self.applicationController.layerClient;
            controller.persistanceManager = self.applicationController.persistenceManager;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }];
}

- (void) contactsSelectionViewControllerDidCancel:(LSContactListViewController *)contactsSelectionViewController
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark
#pragma mark Notification Observer Delegate Methods

- (void) observerWillChangeContent:(LSNotificationObserver *)observer
{
    //Nothing for now
}

- (void)observer:(LSNotificationObserver *)observer didChangeObject:(id)object atIndex:(NSUInteger)index forChangeType:(LYRObjectChangeType)changeType newIndexPath:(NSUInteger)newIndex
{
    // Nothing for now
}

- (void) observerDidChangeContent:(LSNotificationObserver *)observer
{
    [self fetchLayerConversations];
}

#pragma mark - LSVersionView add method

- (void)addVersionView
{
    self.versionView = [[LSVersionView alloc] initWithFrame:CGRectZero];
    self.versionView.topLabel.text = [LSApplicationController versionString];
    self.versionView.bottomLabel.text = [LSApplicationController buildInformationString];
    
    [self.versionView sizeToFit];
    
    [self.tableView addSubview:self.versionView];
    
    self.versionView.frame = CGRectMake((int)(self.tableView.frame.size.width / 2.0 - self.versionView.frame.size.width / 2.0),
                                        -self.versionView.frame.size.height,
                                        self.versionView.frame.size.width,
                                        self.versionView.frame.size.height);
}


@end
