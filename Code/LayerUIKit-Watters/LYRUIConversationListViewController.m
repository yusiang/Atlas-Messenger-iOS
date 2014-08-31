//
//  LYRUIConversationListViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIConversationListViewController.h"
#import "LYRDataSourceChange.h"
#import "LYRUIConstants.h"

@interface LYRUIConversationListViewController () <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSSet *conversations;
@property (nonatomic, strong) NSMutableSet *filteredConversations;
@property (nonatomic, strong) LYRClient *layerClient;

@end

@implementation LYRUIConversationListViewController

static NSString *const LYRUIConversationCellReuseIdentifier = @"conversationCellReuseIdentifier";

+ (instancetype)conversationListViewControllerWithLayerClient:(LYRClient *)layerClient
{
    NSAssert(layerClient, @"layerClient cannot be nil");
    return [[self alloc] initConversationlistViewControllerWithLayerClient:layerClient];
}

- (id)initConversationlistViewControllerWithLayerClient:(LYRClient *)layerClient
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)  {
        
        self.title = @"Conversations";
        self.accessibilityLabel = @"Conversations";
        
        _layerClient = layerClient;
        _conversations = [layerClient conversationsForIdentifiers:nil];
        
        self.allowsEditing = YES;
        self.cellClass = [LYRUIConversationTableViewCell class];
        self.rowHeight = 80;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.delegate = self;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    
    self.tableView.contentOffset = CGPointMake(0, 40);
    self.tableView.tableHeaderView = self.searchBar;
    
    [[LYRUIConversationTableViewCell appearance] setTitleFont:LSMediumFont(14)];
    [[LYRUIConversationTableViewCell appearance] setTitleColor:[UIColor blackColor]];
    [[LYRUIConversationTableViewCell appearance] setSubtitleFont:LSMediumFont(12)];
    [[LYRUIConversationTableViewCell appearance] setSubtitleColor:[UIColor grayColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableView.rowHeight = self.rowHeight;
    [self.tableView registerClass:self.cellClass forCellReuseIdentifier:LYRUIConversationCellReuseIdentifier];
    
    self.searchController.searchResultsTableView.rowHeight = self.rowHeight;
    [self.searchController.searchResultsTableView registerClass:self.cellClass forCellReuseIdentifier:LYRUIConversationCellReuseIdentifier];
    
    if (self.allowsEditing) {
        [self addEditButton];
    }
}

- (void)addEditButton
{
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(editButtonTapped)];
    editButtonItem.accessibilityLabel = @"Edit";
    self.navigationItem.leftBarButtonItem = editButtonItem;
}

- (BOOL)isSearching
{
    return self.searchController.active;
}

- (NSSet *)currentDataSet
{
    if (self.isSearching) {
        return self.filteredConversations;
    }
    return self.conversations;
}

#pragma mark - Public setters

- (void) setCellClass:(Class<LYRUIConversationPresenting>)cellClass
{
    //TODO Raise if this gets set after TV is on screen. How?
    _cellClass = cellClass;
}

- (void)setRowHeight:(CGFloat)rowHeight
{
    //TODO Raise if this gets set after TV is on screen. How?
    _rowHeight = rowHeight;
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
    //TODO Figure out if we want to perform search or force developers
}

#pragma mark - Table view data source methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self currentDataSet] allObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LYRConversation *conversation = [[[self currentDataSet] allObjects] objectAtIndex:indexPath.row];
    NSString *conversationLabel = [self.delegate conversationLabelForParticipants:conversation.participants inConversationListViewController:self];
    
   UITableViewCell<LYRUIConversationPresenting> *conversationCell = [tableView dequeueReusableCellWithIdentifier:LYRUIConversationCellReuseIdentifier forIndexPath:indexPath];
    [conversationCell presentConversation:conversation withLabel:conversationLabel];
    
    return conversationCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.allowsEditing;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.layerClient deleteConversation:[[[self currentDataSet] allObjects] objectAtIndex:indexPath.row] error:nil];
    }
}

#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate conversationListViewController:self didSelectConversation:[[[self currentDataSet] allObjects] objectAtIndex:indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.rowHeight) {
        return self.rowHeight;
    }
    return 80;
}

#pragma mark - Conversation Editing Methods

- (void)editButtonTapped
{
    [self.tableView setEditing:YES animated:YES];
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(doneButtonTapped)];
    doneButtonItem.accessibilityLabel = @"Done";
    self.navigationItem.leftBarButtonItem = doneButtonItem;
}

- (void)doneButtonTapped
{
    [self.tableView setEditing:NO animated:YES];
    [self addEditButton];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - Reload data
- (void)reloadConversations
{
    if (self.searchController.active) {
        [self.searchController.searchResultsTableView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark - TableView Cell Animations

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