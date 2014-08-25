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

@interface LSConversationListViewController () <LSNotificationObserverDelegate, LSContactsSelectionViewControllerDelegate>

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
    
    NSAssert(self.layerClient, @"`self.layerClient` cannot be nil");
    NSAssert(self.persistenceManager, @"persistenceManager cannot be nil");
    NSAssert(self.APIManager, @"APIManager cannot be nil");
    
    self.title = @"Conversations";
    self.accessibilityLabel = @"Conversation List";
    
    // Setup Navigation Item
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logout"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(logoutTapped)];
    logoutButton.accessibilityLabel = @"logout";
    [self.navigationItem setLeftBarButtonItem:logoutButton];
    
    UIBarButtonItem *newConversationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"compose"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(newConversationTapped)];
    newConversationButton.accessibilityLabel = @"New";
    [self.navigationItem setRightBarButtonItem:newConversationButton];
    
    [self addVersionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self fetchLayerConversations];
    
    self.notificationObserver = [[LSNotificationObserver alloc] initWithClient:self.layerClient conversations:self.conversations];
    self.notificationObserver.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.notificationObserver = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)fetchLayerConversations
{
    NSAssert(self.layerClient, @"Layer Controller should not be `nil`.");
    if (self.conversations) self.conversations = nil;
    NSSet *conversations = (NSSet *)[self.layerClient conversationsForIdentifiers:nil];
    self.conversations = [[conversations allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastMessage.sentAt" ascending:NO]]];
    self.filteredConversations = [conversations allObjects];
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
    return [LSConversationCellPresenter presenterWithConversation:[[self currentDataArray] objectAtIndex:index] persistanceManager:self.persistenceManager];
}

- (void)conversationListViewController:(LYRConversationListViewController *)conversationListViewController deleteConversationAtIndex:(NSUInteger)index
{
    NSError *error;
    BOOL success = [self.layerClient deleteConversation:[[self currentDataArray] objectAtIndex:index] error:&error];
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

- (void)conversationListViewController:(LYRConversationListViewController *)conversationListViewcontroller didSelectConversationAtIndex:(NSUInteger)index
{
    LSConversationViewController *viewController = [LSConversationViewController new];
    viewController.conversation = [[self currentDataArray] objectAtIndex:index];
    viewController.layerClient = self.layerClient;
    viewController.persistanceManager = self.persistenceManager;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)conversationListViewController:(LYRConversationListViewController *)conversationListViewController didSearchWithString:(NSString *)searchString completion:(void (^)())completion
{
    NSSet *allUsers = [self.persistenceManager persistedUsersWithError:NULL];
    
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

- (void)contactsSelectionViewControllerDidCancel:(LSContactsSelectionViewController *)contactsSelectionViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark Notification Observer Delegate Methods

- (void) observerinChangeContent:(LSNotificationObserver *)observer
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

#pragma mark
#pragma mark Bar Button Functionality Methods

- (void)logoutTapped
{
    [SVProgressHUD show];
    [self.APIManager deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        NSLog(@"Deauthenticated...");
    }];
}

- (void)newConversationTapped
{
    LSContactsSelectionViewController *contactsViewController = [LSContactsSelectionViewController new];
    contactsViewController.APIManager = self.APIManager;
    contactsViewController.persistenceManager = self.persistenceManager;
    contactsViewController.delegate = self;
    
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
            LYRConversation *conversation = [[self.layerClient conversationsForParticipants:participants] anyObject];
            
            if (!conversation) {
                conversation = [LYRConversation conversationWithParticipants:participants];
            }
            
            controller.conversation = conversation;
            controller.layerClient = self.layerClient;
            controller.persistanceManager = self.persistenceManager;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }];
}

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
