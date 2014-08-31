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
#import "LYRContactListHeader.h"
#import "LSUIConstants.h"

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
    
    self.tableView.rowHeight = 80.0f;
    self.tableView.sectionFooterHeight = 0.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    self.contactTableViewCell = [LYRContactTableViewCell new];
    [self.tableView registerClass:[self.contactTableViewCell class] forCellReuseIdentifier:LYRContactCellIdentifier];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.delegate = self;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    
    self.searchController.searchResultsTableView.rowHeight = 80.0f;
    [self.searchController.searchResultsTableView registerClass:[self.contactTableViewCell class] forCellReuseIdentifier:LYRContactCellIdentifier];
    
    [self configureCellAppearance];
    
    self.tableView.contentOffset = CGPointMake(0, 40);
    self.tableView.tableHeaderView = self.searchBar;
}

- (BOOL)isSearching
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
    return 58;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
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
    id<LYRContactCellPresenter> presenter = [self.dataSource contactListViewController:self presenterForContactAtIndexPath:indexPath];
    UIControl *selectionIndicator = [self.delegate contactListViewController:self selectionIndicatorForContactAtIndexPath:indexPath];
    
    // Configure the cell...
    [contactCell updateWithPresenter:presenter];
    [contactCell updateWithSelectionIndicator:selectionIndicator];
    return contactCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(contactListViewController:didSelectContactAtIndexPath:)]) {
        [self.delegate contactListViewController:self didSelectContactAtIndexPath:indexPath];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(contactListViewController:letterForContactsInSection:)]) {
        return [[LYRContactListHeader alloc] initWithKey:[self.delegate contactListViewController:self letterForContactsInSection:section]];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)configureCellAppearance
{
    [[UILabel appearanceWhenContainedIn:[self.contactTableViewCell class], nil] setFont:LSMediumFont(28)];
}

- (void)reloadContacts
{
    if (self.isSearching) {
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
