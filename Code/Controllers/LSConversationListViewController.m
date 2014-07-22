//
//  LSConversationListViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 7/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSConversationListViewController.h"
#import "LSContactsSelectionViewController.h"
#import "LSConversationCell.h"
#import "LSUIConstants.h"
#import "LSUtilities.h"

@interface LSConversationListViewController () <LSContactsSelectionViewControllerDelegate, LSNotificationObserverDelegate>

@property (nonatomic, strong) NSArray *conversations;
@property (nonatomic, strong) LSNotificationObserver *notificationObserver;

@end

@implementation LSConversationListViewController

static NSString *const LSConversationCellID = @"conversationCellIdentifier";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    NSAssert(self.layerClient, @"`self.layerClient` cannot be nil");
    NSAssert(self.persistenceManager, @"persistenceManager cannot be nil");
    NSAssert(self.APIManager, @"APIManager cannot be nil");
    [super viewDidLoad];
    
    self.title = @"Conversations";
    self.accessibilityLabel = @"Conversation List";
    
    // Setup Navigation Item
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutTapped)];
    logoutButton.accessibilityLabel = @"logout";
    [self.navigationItem setLeftBarButtonItem:logoutButton];
    
    UIBarButtonItem *newConversationButton = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(newConversationTapped)];
    newConversationButton.accessibilityLabel = @"New";
    [self.navigationItem setRightBarButtonItem:newConversationButton];
    
    // Setup Collection View
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[LSConversationCell class] forCellReuseIdentifier:LSConversationCellID];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchLayerConversations];
    [self.tableView reloadData];
    
    self.notificationObserver = [[LSNotificationObserver alloc] initWithClient:self.layerClient conversations:self.conversations];
    self.notificationObserver.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.notificationObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification
{
    NSLog(@"Received notification: %@", notification);
    [self fetchLayerConversations];
    [self.tableView reloadData];
}

- (void)fetchLayerConversations
{
    NSAssert(self.layerClient, @"Layer Controller should not be `nil`.");
    if (self.conversations) self.conversations = nil;
    NSSet *conversations = (NSSet *)[self.layerClient conversationsForIdentifiers:nil];
    self.conversations = [[conversations allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastMessage.sentAt" ascending:NO]]];
}

- (void)conversationsUpdated:(NSNotification *)notification
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.conversations.count;
}

- (LSConversationCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LSConversationCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSConversationCellID];
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(LSConversationCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    LYRConversation *conversation = [self.conversations objectAtIndex:indexPath.row];
    LYRMessage *lastMessage = [[self.layerClient messagesForConversation:conversation] lastObject];
    LSConversationCellPresenter *presenter = [LSConversationCellPresenter presenterWithConversation:conversation
                                                                                            message:lastMessage
                                                                                 persistanceManager:self.persistenceManager];
    [cell updateWithPresenter:presenter];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LSConversationViewController *viewController = [LSConversationViewController new];
    viewController.conversation = [self.conversations objectAtIndex:indexPath.row];
    viewController.layerClient = self.layerClient;
    viewController.persistanceManager = self.persistenceManager;
    viewController.notificationObserver = self.notificationObserver;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark
#pragma mark Bar Button Functionality Methods

- (void)logoutTapped
{
    [self.APIManager deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        self.tableView = nil;
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
            LYRConversation *conversation = [LYRConversation conversationWithParticipants:[[contacts valueForKey:@"userID"] allObjects]];
            controller.conversation = conversation;
            controller.layerClient = self.layerClient;
            controller.persistanceManager = self.persistenceManager;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }];
}

- (void)contactsSelectionViewControllerDidCancel:(LSContactsSelectionViewController *)contactsSelectionViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSError *error;
        BOOL success = [self.layerClient deleteConversation:[self.conversations objectAtIndex:indexPath.row] error:&error];
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
    [self.tableView reloadData];
}
@end
