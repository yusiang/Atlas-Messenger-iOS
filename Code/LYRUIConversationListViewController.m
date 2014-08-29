//
//  LYRUIConversationListViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIConversationListViewController.h"
#import "LYRDataSourceChange.h"

@interface LYRUIConversationListViewController () <UISearchBarDelegate, UISearchDisplayDelegate>

/// The search bar used for search.
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSSet *conversations;
@property (nonatomic, strong) LYRClient *layerClient;

@end

@implementation LYRUIConversationListViewController

static NSString *const LYRUIConversationCellReuseIdentifier = @"LYRConversationCellReuseIdentifier";

+ (instancetype)conversationListViewControllerWithLayerClient:(LYRClient *)layerClient
{
    return [[self alloc] initConversationlistViewControllerWithLayerClient:layerClient];
}

- (id)initConversationlistViewControllerWithLayerClient:(LYRClient *)layerClient
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)  {
        
        _layerClient = layerClient;
        _conversations = [layerClient conversationsForIdentifiers:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cellClass = [LYRUIConversationTableViewCell class];
    
    self.tableView.rowHeight = 80.0f;
    [self.tableView registerClass:self.cellClass forCellReuseIdentifier:LYRUIConversationCellReuseIdentifier];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.delegate = self;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    
    self.searchController.searchResultsTableView.rowHeight = 80.0f;
    [self.searchController.searchResultsTableView registerClass:self.cellClass forCellReuseIdentifier:LYRUIConversationCellReuseIdentifier];
    
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
    // We react to changes
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    // We respond to ending the search
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // We perform the search
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.rowHeight) {
        return self.rowHeight;
    }
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.conversations allObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LYRConversation *conversation = [[self.conversations allObjects] objectAtIndex:indexPath.row];
    NSString *conversationLabel = [self.delegate conversationLabelForParticipants:conversation.participants inConversationListViewController:self];
    
    LYRUIConversationTableViewCell *conversationCell = [tableView dequeueReusableCellWithIdentifier:LYRUIConversationCellReuseIdentifier forIndexPath:indexPath];
    [conversationCell presentConversation:conversation withLabel:conversationLabel];
    
    return conversationCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate conversationListViewController:self didSelectConversation:[[self.conversations allObjects] objectAtIndex:indexPath.row]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.allowsEditing;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.layerClient deleteConversation:[[self.conversations allObjects] objectAtIndex:indexPath.row] error:nil];
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