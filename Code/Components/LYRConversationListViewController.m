//
//  LYRConversationListViewController.m
//  LayerSample
//
//  Created by Zac White on 8/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRConversationListViewController.h"
#import "ZacConversationExample.h"
#import "LYRDataSourceChange.h"
#import "LYRConversationCell.h"

@interface LYRConversationListViewController () <UISearchDisplayDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UISearchDisplayController *searchController;
@property (strong, nonatomic) UISearchBar *searchBar;

@end

static NSString* const LYRConversationCellReuseIdentifier = @"LYRConversationCellReuseIdentifier";

@implementation LYRConversationListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dataSource = self;
    self.delegate = self;
    
    self.tableView.rowHeight = 80.0f;
    [self.tableView registerClass:[LYRConversationCell class] forCellReuseIdentifier:LYRConversationCellReuseIdentifier];

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.delegate = self;

    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;

    self.searchController.searchResultsTableView.rowHeight = 80.0f;
    [self.searchController.searchResultsTableView registerClass:[LYRConversationCell class] forCellReuseIdentifier:LYRConversationCellReuseIdentifier];

    self.tableView.contentOffset = CGPointMake(0, 40);
    self.tableView.tableHeaderView = self.searchBar;
}

- (BOOL)searchActive
{
    return self.searchController.active;
}

#pragma mark - UISearchDisplayDelegate Methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    // call to our delegate.
    if ([self.dataSource respondsToSelector:@selector(conversationListViewControllerWillBeginSearch:)]) {
        [self.dataSource conversationListViewControllerWillBeginSearch:self];
    }
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    // call to our delegate.
    if ([self.dataSource respondsToSelector:@selector(conversationListViewControllerDidEndSearch:)]) {
        [self.dataSource conversationListViewControllerDidEndSearch:self];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([self.dataSource respondsToSelector:@selector(conversationListViewController:didSearchWithString:completion:)]) {
        [self.dataSource conversationListViewController:self didSearchWithString:searchText completion:^{
            [self reloadConversations];
        }];
    }
}

#pragma mark - LYRConversationListViewControllerDataSource

- (NSUInteger)numberOfConversationsInViewController:(LYRConversationListViewController *)conversationListViewController
{
    return 0;
}

- (id<LYRConversationCellPresenter>)conversationListViewController:(LYRConversationListViewController *)conversationListViewController presenterForConversationAtIndex:(NSUInteger)index
{
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.dataSource respondsToSelector:@selector(numberOfConversationsInViewController:)]) {
        return [self.dataSource numberOfConversationsInViewController:self];
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LYRConversationCell *conversationCell = [tableView dequeueReusableCellWithIdentifier:LYRConversationCellReuseIdentifier forIndexPath:indexPath];

    NSAssert([self.dataSource respondsToSelector:@selector(conversationListViewController:presenterForConversationAtIndex:)], @"The dataSource must implement conversationListViewController:presenterForConversationAtIndex:");
    id<LYRConversationCellPresenter> presenter = [self.dataSource conversationListViewController:self presenterForConversationAtIndex:indexPath.row];

    // Configure the cell...
    [conversationCell updateWithPresenter:presenter];

    return conversationCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(conversationListViewController:didSelectConversationAtIndex:)]) {
        [self.delegate conversationListViewController:self didSelectConversationAtIndex:indexPath.row];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource respondsToSelector:@selector(conversationListViewController:deleteConversationAtIndex:)];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        // Inform the data source that a deletion has occurred. But we'll get back a
        // reloadConversations or an applyConversationChanges based on the deletion, so don't optimistically delete.
        if ([self.dataSource respondsToSelector:@selector(conversationListViewController:deleteConversationAtIndex:)]) {
            [self.dataSource conversationListViewController:self deleteConversationAtIndex:indexPath.row];
        }
    }
}

- (void)reloadConversations
{
    if (self.searchController.active) {
        [self.searchController.searchResultsTableView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

- (void)applyConversationChanges:(NSArray *)changes
{
    [self.tableView beginUpdates];

    for (LYRDataSourceChange *change in changes) {
        if (change.type == LYRDataSourceChangeTypeUpdate) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:change.newIndex inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        } else if (change.type == LYRDataSourceChangeTypeInsert) {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:change.newIndex inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        } else if (change.type == LYRDataSourceChangeTypeMove) {
            [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:change.oldIndex inSection:0]
                                   toIndexPath:[NSIndexPath indexPathForRow:change.newIndex inSection:0]];
        } else if (change.type == LYRDataSourceChangeTypeDelete) {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:change.newIndex inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }

    [self.tableView endUpdates];
}

@end
