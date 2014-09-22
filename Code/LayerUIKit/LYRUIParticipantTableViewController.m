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
#import "LYRUIConstants.h"
#import "LYRUIParticipantPickerController.h"

@interface LYRUIParticipantTableViewController () <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSDictionary *sortedParticipants;
@property (nonatomic, strong) NSDictionary *filteredParticipants;
@property (nonatomic, strong) NSMutableSet *selectedParticipants;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic) LYRUIParticipantPickerSortType sortType;

@end

@implementation LYRUIParticipantTableViewController

NSString *const LYRParticipantCellIdentifier = @"participantCellIdentifier";

+ (instancetype)participantTableViewControllerWithParticipants:(NSSet *)participants sortType:(LYRUIParticipantPickerSortType)sortType
{
    return [[self alloc] initWithParticipants:participants sortType:sortType];
}

- (id)initWithParticipants:(NSSet *)participants sortType:(LYRUIParticipantPickerSortType)sortType
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        self.sortType = sortType;
        self.participants = participants;
        self.sortedParticipants = [self sortAndGroupContactListByAlphabet:self.participants];
        
        self.title = @"Participants";
        self.accessibilityLabel = @"Participants";
        
        self.selectionIndicator = [LYRUISelectionIndicator initWithDiameter:30];
        self.selectedParticipants = [[NSMutableSet alloc] init];
        
        [self configureAppearance];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.accessibilityLabel = @"Search Bar";
    self.searchBar.delegate = self;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchController.delegate = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    
    self.tableView.allowsMultipleSelection = self.allowsMultipleSelection;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionFooterHeight = 0.0;
    self.tableView.tableHeaderView = self.searchBar;
    
    self.tableView.sectionHeaderHeight = 40.0;
    
    self.filteredParticipants = self.sortedParticipants;
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableView.rowHeight = self.rowHeight;
    [self.tableView registerClass:self.participantCellClass forCellReuseIdentifier:LYRParticipantCellIdentifier];
    
    self.searchController.searchResultsTableView.rowHeight = self.rowHeight;
    [self.searchController.searchResultsTableView registerClass:self.participantCellClass forCellReuseIdentifier:LYRParticipantCellIdentifier];
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    _allowsMultipleSelection = allowsMultipleSelection;
    self.tableView.allowsMultipleSelection = allowsMultipleSelection;
}

- (NSDictionary *)currentDataArray
{
    if (self.isSearching) {
        return self.filteredParticipants;
    }
    return self.sortedParticipants;
}

- (BOOL)isSearching
{
    return self.searchController.active;
}

#pragma mark - UISearchDisplayDelegate Methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    //
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //
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
    return self.rowHeight;
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:section];
    return [[LYRUIPaticipantSectionHeaderView alloc] initWithKey:key];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[tableView indexPathsForSelectedRows] containsObject:indexPath]) {
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    } else {
        return indexPath;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:indexPath.section];
    id<LYRUIParticipant> participant = [[[self currentDataArray] objectForKey:key] objectAtIndex:indexPath.row];
    [self.delegate participantTableViewController:self didSelectParticipant:participant];
}

#pragma mark UIBarButtonItem implementation methods
- (void)cancelButtonTapped
{
    [self.delegate participantTableViewControllerDidSelectCancelButton];
}

- (void)doneButtonTapped
{
    for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
         NSString *key = [[self sortedContactKeys] objectAtIndex:indexPath.section];
        id<LYRUIParticipant> participant = [[[self currentDataArray] objectForKey:key] objectAtIndex:indexPath.row];
        [self.selectedParticipants addObject:participant];
    }
    [self.delegate participantTableViewControllerDidSelectDoneButtonWithSelectedParticipants:self.selectedParticipants];
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
    [self.delegate participantTableViewController:self didSearchWithString:searchText completion:^(NSSet *filteredParticipants) {
        completion([self sortAndGroupContactListByAlphabet:filteredParticipants]);
    }];
}

- (NSArray *)sortedContactKeys
{
    NSMutableArray *mutableKeys = [NSMutableArray arrayWithArray:[[self currentDataArray] allKeys]];
    [mutableKeys sortUsingSelector:@selector(compare:)];
    return mutableKeys;
}

- (NSDictionary *)sortAndGroupContactListByAlphabet:(NSSet *)participants
{
    NSArray *sortedParticipants;
    
    switch (self.sortType) {
        case LYRUIParticipantPickerControllerSortTypeFirst:
            sortedParticipants = [[participants allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]]];
            break;
        case LYRUIParticipantPickerControllerSortTypeLast:
            sortedParticipants = [[participants allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]]];
            break;
        default:
            break;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (id<LYRUIParticipant>participant in sortedParticipants) {
        NSString *sortName;
        switch (self.sortType) {
            case LYRUIParticipantPickerControllerSortTypeFirst:
                sortName = participant.firstName;
                break;
            case LYRUIParticipantPickerControllerSortTypeLast:
                sortName = participant.lastName;
                break;
            default:
                break;
        }
        
        NSString *firstLetter = [[sortName substringToIndex:1] uppercaseString];
        NSMutableArray *letterList = [dict objectForKey:firstLetter];
        if (!letterList) {
            letterList = [NSMutableArray array];
        }
        [letterList addObject:participant];
        [dict setObject:letterList forKey:firstLetter];
    }
    return dict;
}

- (void)configureAppearance
{
    [[LYRUIParticipantTableViewCell appearance] setTitleColor:[UIColor blackColor]];
    [[LYRUIParticipantTableViewCell appearance] setTitleFont:LSLightFont(14)];
}

@end
