//
//  LSConversationListVC.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSConversationListViewController.h"
#import "LSConversationCell.h"
#import "LYRSampleConversation.h"
#import "LSContactsViewController.h"
#import "LSUIConstants.h"


@interface LSConversationListViewController ()

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSOrderedSet *conversations;
@property (nonatomic) BOOL onScreen;

@end

@implementation LSConversationListViewController

NSString *const LSConversationCellIdentifier = @"conversationCellIdentifier";

- (id) init
{
    self = [super init];
    if(self) {
        self.title = @"Conversations";
        self.accessibilityLabel = @"Conversation List";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeBarButtons];
    [self initializeCollectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
    self.onScreen = TRUE;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.onScreen = FALSE;
}

- (void)setLayerController:(LSLayerController *)layerController
{
    if(!_layerController) {
        _layerController = layerController;
    }
    [self fetchLayerConversations];
}

- (void)fetchLayerConversations
{
    NSAssert(self.layerController, @"Layer Controller should not be `nil`.");
    NSOrderedSet *conversations = [self.layerController.client conversationsForIdentifiers:nil];
    self.conversations = conversations;
    
    //Doing this for now in place of notifications to changes in the DB
    if (!self.conversations.count > 0 && self.onScreen){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self fetchLayerConversations];
            [self.collectionView reloadData];
        });
    }
}

- (void)initializeBarButtons
{
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutTapped)];
    logoutButton.accessibilityLabel = @"logout";
    [self.navigationItem setLeftBarButtonItem:logoutButton];
    
    UIBarButtonItem *newConversationButton = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(newConversationTapped)];
    newConversationButton.accessibilityLabel = @"new";
    [self.navigationItem setRightBarButtonItem:newConversationButton];
}

- (void)initializeCollectionView
{
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
    return CGSizeMake(320, 80);
}

- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
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
        [self.layerController.client stop];
    }];
}

- (void)newConversationTapped
{
    LSContactsViewController *contactsViewController = [[LSContactsViewController alloc] init];
    contactsViewController.layerController = self.layerController;
    
    [self.navigationController pushViewController:contactsViewController animated:TRUE];
}

@end
