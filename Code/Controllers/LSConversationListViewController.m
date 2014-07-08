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

@interface LSConversationListViewController () <LSContactsSelectionViewControllerDelegate>

@property (nonatomic, strong) NSOrderedSet *conversations;

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
    
    // TODO: Nothing is removing this....
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationsUpdated:) name:@"conversationsUpdated" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchLayerConversations];
    [self.tableView reloadData];
}

- (void)fetchLayerConversations
{
    if (self.navigationController.topViewController == self) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"conversationsUpdated" object:nil userInfo:nil];
            [self fetchLayerConversations];
        });
    }
    
    NSAssert(self.layerClient, @"Layer Controller should not be `nil`.");
    if (self.conversations) self.conversations = nil;
    NSOrderedSet *conversations = [self.layerClient conversationsForIdentifiers:nil];
    NSLog(@"%lu Conversations For Authenticated User", (unsigned long)conversations.count);
    self.conversations = conversations;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - LSContactsSelectionViewControllerDelegate methods

- (void)contactsSelectionViewController:(LSContactsSelectionViewController *)contactsSelectionViewController didSelectContacts:(NSSet *)contacts
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (contacts.count > 0) {
            LSConversationViewController *controller = [LSConversationViewController new];
            LYRConversation *conversation = [self.layerClient conversationWithIdentifier:nil participants:[[contacts valueForKey:@"userID"] allObjects]];
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
        }
    }
}
@end
