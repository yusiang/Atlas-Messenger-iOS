//
//  LYRContactListViewController.m
//  LayerSample
//
//  Created by Zac White on 8/21/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRContactListViewController.h"
#import "LYRContactTableViewCell.h"
#import "LYRDataSourceChange.h"

@interface LYRContactListViewController () <UISearchDisplayDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UISearchDisplayController *searchController;
@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation LYRContactListViewController

NSString *const LYRContactCellIdentifier = @"contactCellIdentifier";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    
    self.tableView.rowHeight = 80.0f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    [self.tableView registerClass:[LYRContactTableViewCell class] forCellReuseIdentifier:LYRContactCellIdentifier];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.delegate = self;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    
    self.searchController.searchResultsTableView.rowHeight = 80.0f;
    [self.searchController.searchResultsTableView registerClass:[LYRContactTableViewCell class] forCellReuseIdentifier:LYRContactCellIdentifier];
    
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
    if ([self.dataSource respondsToSelector:@selector(contactListViewControllerWillBeginSearch:)]) {
        [self.dataSource contactListViewControllerWillBeginSearch:self];
    }
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    // call to our delegate.
    if ([self.dataSource respondsToSelector:@selector(contactListViewControllerDidEndSearch:)]) {
        [self.dataSource contactListViewControllerDidEndSearch:self];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([self.dataSource respondsToSelector:@selector(contactListViewController:didSearchWithString:completion:)]) {
        [self.dataSource contactListViewController:self didSearchWithString:searchText completion:^{
            [self reloadContacts];
        }];
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource respondsToSelector:@selector(contactListViewController:heightForContactAtIndexPath:)]) {
        return [self.delegate contactListViewController:self heightForContactAtIndexPath:indexPath];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.dataSource respondsToSelector:@selector(contactListViewController:numberOfContactsInSection:)]) {
        return [self.dataSource contactListViewController:self numberOfContactsInSection:section];
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInViewController:)]) {
        return [self.dataSource numberOfSectionsInViewController:self];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LYRContactTableViewCell *contactCell = [tableView dequeueReusableCellWithIdentifier:LYRContactCellIdentifier forIndexPath:indexPath];
    
    NSAssert([self.dataSource respondsToSelector:@selector(contactListViewController:presenterForContactAtIndexPath:)], @"The dataSource must implement conversationListViewController:presenterForConversationAtIndex:");
    id<LYRContactPresenter> presenter = [self.dataSource contactListViewController:self presenterForContactAtIndexPath:indexPath];
    
    // Configure the cell...
    [contactCell updateWithPresenter:presenter];
    
    return contactCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(contactListViewController:didSelectContactAtIndexPath:)]) {
        [self.delegate contactListViewController:self didSelectContactAtIndexPath:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FALSE;
}

- (void)reloadContacts
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
