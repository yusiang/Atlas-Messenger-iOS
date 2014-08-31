//
//  LYRUIParticipantListViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIParticipantTableViewController.h"
#import "LYRUIPaticipantSectionHeaderView.h"
#import "LYRUISelectionIndicator.h"

@interface LYRUIParticipantTableViewController () <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSDictionary *filteredParticipants;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation LYRUIParticipantTableViewController

NSString *const LYRParticipantCellIdentifier = @"participantCellIdentifier";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        self.title = @"Participants";
        self.accessibilityLabel = @"Participants";
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selectionIndicator = [LYRUISelectionIndicator initWithDiameter:20];
    
    self.filteredParticipants = self.participants;
    
    self.participantCellClass = [LYRUIParticipantTableViewCell class];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.delegate = self;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsTableView.rowHeight = 80.0f;
    [self.searchController.searchResultsTableView registerClass:self.participantCellClass forCellReuseIdentifier:LYRParticipantCellIdentifier];
    
    self.tableView.rowHeight = 80.0f;
    self.tableView.sectionFooterHeight = 0.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.contentOffset = CGPointMake(0, 40);
    self.tableView.tableHeaderView = self.searchBar;
    [self.tableView registerClass:self.participantCellClass forCellReuseIdentifier:LYRParticipantCellIdentifier];
    
    // Left bar button item is the text Cancel
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(cancelButtonTapped)];
    cancelButtonItem.accessibilityLabel = @"Cancel";
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    // Right bar button item is the text Done
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(doneButtonTapped)];
    doneButtonItem.accessibilityLabel = @"Done";
    self.navigationItem.rightBarButtonItem = doneButtonItem;
}

- (NSDictionary *)currentDataArray
{
    if (self.isSearching) {
        return self.filteredParticipants;
    }
    return self.participants;
}

- (BOOL)isSearching
{
    return self.searchController.active;
}

#pragma mark - UISearchDisplayDelegate Methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    // Don't Care
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    // Don't Care
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterParticipantsWithSearchText:searchText completion:^(NSDictionary *participants) {
        self.filteredParticipants = participants;
        [self reloadContacts];
    }];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self currentDataArray] allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:section];
    return [[[self currentDataArray] objectForKey:key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:indexPath.section];
    id<LYRUIParticipant> participant = [[[self currentDataArray] objectForKey:key] objectAtIndex:indexPath.row];
    
    UITableViewCell <LYRUIParticipantPresenting> *participantCell = [self.tableView dequeueReusableCellWithIdentifier:LYRParticipantCellIdentifier];
    
    [participantCell presentParticipant:participant];
    
    return participantCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:indexPath.section];
    id<LYRUIParticipant> participant = [[[self currentDataArray] objectForKey:key] objectAtIndex:indexPath.row];
    [self.delegate participantTableViewController:self didSelectParticipant:participant];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:section];
    return [[LYRUIPaticipantSectionHeaderView alloc] initWithKey:key];
}

- (void)reloadContacts
{
    if (self.isSearching) {
        [self.searchController.searchResultsTableView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

- (void)filterParticipantsWithSearchText:(NSString *)searchText completion:(void(^)(NSDictionary *participants))completion
{
    [self.delegate participantTableViewController:self didSearchWithString:searchText completion:^(NSDictionary *filteredParticipants) {
        completion(filteredParticipants);
    }];
}

- (NSArray *)sortedContactKeys
{
    NSMutableArray *mutableKeys = [NSMutableArray arrayWithArray:[[self currentDataArray] allKeys]];
    [mutableKeys sortUsingSelector:@selector(compare:)];
    return mutableKeys;
}

- (void)cancelButtonTapped
{
    [self.delegate participantTableViewControllerDidSelectCancelButton];
}

- (void)doneButtonTapped
{
    [self.delegate participantTableViewControllerDidSelectDoneButton];
}

@end
