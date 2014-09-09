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
#import "LYRUIChangeNotificationObserver.h"

@interface LYRUIConversationListViewController () <UISearchBarDelegate, UISearchDisplayDelegate, LYRUIChangeNotificationObserverDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSArray *conversations;
@property (nonatomic, strong) NSMutableArray *filteredConversations;
@property (nonatomic, strong) NSPredicate *searchPredicate;
@property (nonatomic, strong) LYRClient *layerClient;
@property (nonatomic, strong) LYRUIChangeNotificationObserver *changeNotificationObserver;
@property (nonatomic) BOOL isOnScreen;

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
        
        // Set properties from designated initializer
        self.layerClient = layerClient;
        
        // Set default configuration for public properties
        [self setCellClass:[LYRUIConversationTableViewCell class]];
        [self setRowHeight:80];
        [self setAllowsEditing:TRUE];
        [self setShowsConversationImage:TRUE];
        
        // Accessibility
        self.title = @"Conversations";
        self.accessibilityLabel = @"Conversations";
        
    }
    return self;
}

- (id) init
{
    [NSException raise:@"Invalid" format:@"Failed to call designated initializer"];
    return nil;
}

#pragma mark - VC Lifecycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self fetchLayerConversations];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.accessibilityLabel = @"Search Bar";
    self.searchBar.delegate = self;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    
    self.tableView.tableHeaderView = self.searchBar;
    self.tableView.accessibilityLabel = @"Conversation List";
    
    [self.tableView setContentOffset:CGPointMake(0, 44)];
    
    [self configureTableViewCellAppearance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableView.rowHeight = self.rowHeight;
    [self.tableView registerClass:self.cellClass forCellReuseIdentifier:LYRUIConversationCellReuseIdentifier];
    
    self.searchController.searchResultsTableView.rowHeight = self.rowHeight;
    [self.searchController.searchResultsTableView registerClass:self.cellClass forCellReuseIdentifier:LYRUIConversationCellReuseIdentifier];
    
    self.changeNotificationObserver = [[LYRUIChangeNotificationObserver alloc] initWithClient:self.layerClient conversations:self.conversations];
    self.changeNotificationObserver.delegate = self;
    
    if (self.allowsEditing) {
        [self addEditButton];
    }
    
    self.isOnScreen = TRUE;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.isOnScreen = NO;
}

#pragma mark - Public setters

- (void)setAllowsEditing:(BOOL)allowsEditing
{
    if (self.isOnScreen) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot set editing mode after the view has been loaded" userInfo:nil];
    }
    
    _allowsEditing = allowsEditing;

    if (self.navigationItem.leftBarButtonItem && !allowsEditing) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void) setCellClass:(Class<LYRUIConversationPresenting>)cellClass
{
    if (self.isOnScreen) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot set cellClass after the view has been loaded" userInfo:nil];
    }
    
    if (![cellClass conformsToProtocol:@protocol(LYRUIConversationPresenting)]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cell class cellClass must conform to LYRUIConversationPresenting Protocol" userInfo:nil];

    }
    _cellClass = cellClass;
}

- (void)setRowHeight:(CGFloat)rowHeight
{
    if (self.isOnScreen) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot set rowHeight after the view has been loaded" userInfo:nil];
    }
    _rowHeight = rowHeight;
}

#pragma mark - Navigation Bar Edit Button

- (void)addEditButton
{
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(editButtonTapped)];
    editButtonItem.accessibilityLabel = @"Edit";
    self.navigationItem.leftBarButtonItem = editButtonItem;
}

#pragma mark Data source load and configuration methods

- (void)fetchLayerConversations
{
    NSSet *conversations = [self.layerClient conversationsForIdentifiers:nil];
    self.conversations = [conversations sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastMessage.sentAt" ascending:NO]]];
    
    if (!self.searchPredicate) {
        self.filteredConversations = [NSMutableArray arrayWithArray:self.conversations];
    } else {
        //[self filterConversationsForSearchPredicate:self.searchPredicate];
    }
    
    [self reloadConversations];
}

- (void)reloadConversations
{
    if (self.searchController.active) {
        [self.searchController.searchResultsTableView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

// Returns appropriate data set depending on search state
- (NSArray *)currentDataSet
{
    if (self.isSearching) {
        return self.filteredConversations;
    }
    return self.conversations;
}

- (BOOL)isSearching
{
    return self.searchController.active;
}

#pragma mark - UISearchDisplayDelegate Methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    // We react to search begining
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    // We respond to ending the search
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{

}

#pragma mark - Table view data source methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self currentDataSet] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LYRConversation *conversation = [[self currentDataSet] objectAtIndex:indexPath.row];
    NSString *conversationLabel = [self.delegate conversationLabelForParticipants:conversation.participants inConversationListViewController:self];
    
    UITableViewCell<LYRUIConversationPresenting> *conversationCell = [tableView dequeueReusableCellWithIdentifier:LYRUIConversationCellReuseIdentifier forIndexPath:indexPath];
    [conversationCell presentConversation:conversation withLabel:conversationLabel];
    [conversationCell shouldShowConversationImage:self.showsConversationImage];
    return conversationCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.allowsEditing;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.layerClient deleteConversation:[[self currentDataSet] objectAtIndex:indexPath.row] error:nil];
    }
}

#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate conversationListViewController:self didSelectConversation:[[self currentDataSet] objectAtIndex:indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.rowHeight;
}

#pragma mark - Conversation Editing Methods

// Set table view into editing mode and change left bar buttong to a done button
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

#pragma mark
#pragma mark Notification Observer Delegate Methods

- (void) observerWillChangeContent:(LYRUIChangeNotificationObserver *)observer
{
    // Nothing for now
}

- (void)observer:(LYRUIChangeNotificationObserver *)observer didChangeObject:(id)object atIndex:(NSUInteger)index forChangeType:(LYRObjectChangeType)changeType newIndexPath:(NSUInteger)newIndex
{
    // Nothing for now
}

- (void) observerDidChangeContent:(LYRUIChangeNotificationObserver *)observer
{
    [self fetchLayerConversations];
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

- (void)configureTableViewCellAppearance
{
    [[LYRUIConversationTableViewCell appearance] setConversationLabelFont:LSLightFont(14)];
    [[LYRUIConversationTableViewCell appearance] setConversationLableColor:[UIColor blackColor]];
    [[LYRUIConversationTableViewCell appearance] setLastMessageTextFont:LSLightFont(12)];
    [[LYRUIConversationTableViewCell appearance] setLastMessageTextColor:[UIColor grayColor]];
    [[LYRUIConversationTableViewCell appearance] setDateLabelFont:LSLightFont(12)];
    [[LYRUIConversationTableViewCell appearance] setDateLabelColor:[UIColor darkGrayColor]];
    [[LYRUIConversationTableViewCell appearance] setBackgroundColor:[UIColor whiteColor]];
}

@end