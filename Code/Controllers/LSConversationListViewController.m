//
//  LSConversationListVC.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSConversationListViewController.h"
#import "LSConversationCell.h"
#import "LSContactsSelectionViewController.h"
#import "LSUIConstants.h"

@interface LSConversationListViewController () <UICollectionViewDataSource, UICollectionViewDelegate, LSContactsSelectionViewControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSOrderedSet *conversations;

@end

@implementation LSConversationListViewController

NSString *const LSConversationCellIdentifier = @"conversationCellIdentifier";

- (void)viewDidLoad
{
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
    newConversationButton.accessibilityLabel = @"new";
    [self.navigationItem setRightBarButtonItem:newConversationButton];
    
    // Setup Collection View
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame
                                             collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[LSConversationCell class] forCellWithReuseIdentifier:LSConversationCellIdentifier];

    // TODO: Nothing is removing this....
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationsUpdated:) name:@"conversationsUpdated" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchLayerConversations];
    [self.collectionView reloadData];
}

- (void)fetchLayerConversations
{
    NSAssert(self.layerClient, @"Layer Controller should not be `nil`.");
    if (self.conversations) self.conversations = nil;
    NSOrderedSet *conversations = [self.layerClient conversationsForIdentifiers:nil];
    self.conversations = conversations;
    
    // SBW: You don't want a method called `fetchLayerConversations` that also does UI changes. I'd probably use KVO on `self.conversations` to drive the reload
    //Doing this for now in place of notifications to changes in the DB
    if (!self.conversations.count > 0 && self.navigationController.topViewController == self){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self fetchLayerConversations];
            [self.collectionView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"conversationsUpdated" object:nil userInfo:nil];
        });
    }
}

- (void)conversationsUpdated:(NSNotification *)notification
{
    
}

# pragma mark
# pragma mark Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"%lu Conversations For Authenticated User", (unsigned long)self.conversations.count);
    return self.conversations.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LSConversationCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:LSConversationCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(LSConversationCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"The conversation is %@", [self.conversations objectAtIndex:indexPath.row]);
    LYRConversation *conversation = [self.conversations objectAtIndex:indexPath.row];
    NSOrderedSet *messages = [self.layerClient messagesForConversation:conversation];
    [cell updateWithConversation:conversation messages:messages];
}

#pragma mark
#pragma mark Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LSConversationViewController *viewController = [LSConversationViewController new];
    viewController.conversation = [self.conversations objectAtIndex:indexPath.row];
    viewController.layerClient = self.layerClient;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     SBW: You can use a static CGSize constant
     
     static CGSize const LSConversationListItemCellSize = { 320, 80 };
     */
    return CGSizeMake(320, 80);
}

- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark
#pragma mark Bar Button Functionality Methods

- (void)logoutTapped
{
    [self.APIManager deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        NSLog(@"Deauthenticated...");
    }];
}

- (void)newConversationTapped
{
    LSContactsSelectionViewController *contactsViewController = [LSContactsSelectionViewController new];
    contactsViewController.persistenceManager = self.persistenceManager;
    contactsViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contactsViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - LSContactsSelectionViewControllerDelegate methods

- (void)contactsSelectionViewController:(LSContactsSelectionViewController *)contactsSelectionViewController didSelectContacts:(NSSet *)contacts
{
    [self dismissViewControllerAnimated:YES completion:^{
        LSConversationViewController *controller = [LSConversationViewController new];
        
        LYRConversation *conversation = [self.layerClient conversationWithIdentifier:nil participants:[[contacts valueForKey:@"userID"] allObjects]];
        controller.conversation = conversation;
        controller.layerClient = self.layerClient;
        [self.navigationController pushViewController:controller animated:YES];
    }];
}

- (void)contactsSelectionViewControllerDidCancel:(LSContactsSelectionViewController *)contactsSelectionViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
