//
//  LSConversationListVC.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSConversationListViewController.h"
#import "LSConversationCell.h"
#import "LSContactsViewController.h"
#import "LSUIConstants.h"
#import "LSUserManager.h"

// SBW: You can declare protocols on the class extension inside the implementation file. The collection view protocols is
// an implementation detail and doesn't need to be exposed publicly.

@interface LSConversationListViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSOrderedSet *conversations;

@end

@implementation LSConversationListViewController

NSString *const LSConversationCellIdentifier = @"conversationCellIdentifier";

- (id) init
{
    self = [super init];
    if(self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // SBW: These are better being set in `viewDidLoad`
    self.title = @"Conversations";
    self.accessibilityLabel = @"Conversation List";
    
    [self initializeBarButtons];
    [self initializeCollectionView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationsUpdated:) name:@"conversationsUpdated" object:nil];
    
    NSAssert(self.layerController, @"`self.layerController` cannot be nil");

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchLayerConversations];
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

/**
 SBW: I'd recommend using a standard accessor and then doing your fetch in `viewDidLoad`.
 */
- (void)setLayerController:(LSLayerController *)layerController
{
    if(!_layerController) {
        _layerController = layerController;
    }
}

- (void)fetchLayerConversations
{
    NSAssert(self.layerController, @"Layer Controller should not be `nil`.");
    if (self.conversations) self.conversations = nil;
    NSOrderedSet *conversations = [self.layerController.client conversationsForIdentifiers:nil];
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

// SBW: I'd probably inline this into `viewDidLoad`
- (void)initializeBarButtons
{
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutTapped)];
    logoutButton.accessibilityLabel = @"logout";
    [self.navigationItem setLeftBarButtonItem:logoutButton];
    
    UIBarButtonItem *newConversationButton = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(newConversationTapped)];
    newConversationButton.accessibilityLabel = @"new";
    [self.navigationItem setRightBarButtonItem:newConversationButton];
}

// SBW: I'd probably inline tis into `viewDidLoad`
- (void)initializeCollectionView
{
    // SBW: Why have you set this up to be tolerant of multiple invocations?
    if (!self.collectionView) {
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame
                                                 collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.collectionView];
    }
    [self.collectionView registerClass:[LSConversationCell class] forCellWithReuseIdentifier:LSConversationCellIdentifier];
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
    [cell updateCellWithConversation:[self.conversations objectAtIndex:indexPath.row] andLayerController:self.layerController];
}

#pragma mark
#pragma mark Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LSConversationViewController *viewController = [[LSConversationViewController alloc] init];
    [viewController setConversation:[self.conversations objectAtIndex:indexPath.row]];
    [viewController setLayerController:self.layerController];
    [self.navigationController pushViewController:viewController animated:TRUE];
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
    // SBW: You can use `UIEdgeInsetsZero`
    return UIEdgeInsetsMake(0, 0, 0, 0);
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
    [self.navigationController dismissViewControllerAnimated:TRUE completion:^{
        [self.layerController logout];
        [[LSUserManager new] logout];
    }];
}

- (void)newConversationTapped
{
    LSContactsViewController *contactsViewController = [[LSContactsViewController alloc] init];
    contactsViewController.layerController = self.layerController;
    
    [self.navigationController pushViewController:contactsViewController animated:TRUE];
}

@end
