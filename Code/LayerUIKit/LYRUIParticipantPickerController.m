//
//  LYRUIParticipantPickerController.m
//  
//
//  Created by Kevin Coleman on 8/29/14.
//
//

#import "LYRUIParticipantPickerController.h"
#import "LYRUISelectionIndicator.h"

@interface LYRUIParticipantPickerController () <LYRUIParticipantTableViewControllerDelegate>

@property (nonatomic) NSSet *participants;
@property (nonatomic) NSDictionary *sortedParticipants;
@property (nonatomic) LYRUIParticipantTableViewController *participantTableViewController;
@property (nonatomic) BOOL isOnScreen;

@end

@implementation LYRUIParticipantPickerController

+ (instancetype)participantPickerWithParticipants:(id<LYRUIParticipantPickerDataSource>)dataSource sortType:(LYRUIParticipantPickerSortType)sortType
{
    NSAssert(dataSource, @"Data Source cannot be nil");
    return [[self alloc] initWithDataSource:dataSource sortType:sortType];
}

- (id)initWithDataSource:(id<LYRUIParticipantPickerDataSource>)dataSource sortType:(LYRUIParticipantPickerSortType)sortType
{
    LYRUIParticipantTableViewController *controller = [[LYRUIParticipantTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self = [super initWithRootViewController:controller];
    if (self) {
        controller.participants = [dataSource participants];
        controller.delegate = self;
        _dataSource = dataSource;
    }
    return self;
}

- (id)init
{
    [NSException raise:@"Invalid" format:@"Failed to call designated initializer"];
    return nil;
}

#pragma mark - VC Lifecycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allowsMultipleSelection = YES;
    self.cellClass = [LYRUIParticipantTableViewCell class];
    self.rowHeight = 48;
    self.participantTableViewController.participantCellClass = self.cellClass;
    self.participantTableViewController.selectionIndicator = [LYRUISelectionIndicator initWithDiameter:30];
    self.title = @"Participants";
    self.accessibilityLabel = @"Participants";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    self.participants = [self.dataSource participants];
    
    self.isOnScreen = TRUE;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isOnScreen = FALSE;
}

#pragma mark Public property setters and getters
- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    if (self.isOnScreen) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change multiple selection mode after view has been loaded" userInfo:nil];
    }
    self.participantTableViewController.allowsMultipleSelection = allowsMultipleSelection;
}

- (BOOL)allowsMultipleSelection
{
    return self.participantTableViewController.allowsMultipleSelection;
}

- (void)setCellClass:(Class<LYRUIParticipantPresenting>)cellClass
{
    if (self.isOnScreen) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change cell class after view has been loaded" userInfo:nil];
    }
    self.participantTableViewController.participantCellClass = cellClass;
}

- (Class<LYRUIParticipantPresenting>)cellClass
{
    return self.participantTableViewController.participantCellClass;
}

- (void)setRowHeight:(CGFloat)rowHeight
{
    if (self.isOnScreen) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change row height after view has been loaded" userInfo:nil];
    }
    self.participantTableViewController.rowHeight = rowHeight;
}

- (CGFloat)rowHeight
{
    return self.participantTableViewController.rowHeight;
}

- (void)setParticipantPickerSortType:(LYRUIParticipantPickerSortType)participantPickerSortType
{
    if (self.isOnScreen) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change sort type after view has been loaded" userInfo:nil];
    }
    _sortType = participantPickerSortType;
}

#pragma mark - Participant Table View Controller Delegate Methods

- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didSelectParticipant:(id<LYRUIParticipant>)participant
{
    if (!self.allowsMultipleSelection || self.participantTableViewController.searchDisplayController.isActive) {
        [self.participantPickerDelegate participantSelectionViewController:self didSelectParticipants:[NSSet setWithObject:participant]];
    }
}

- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didSearchWithString:(NSString *)searchText completion:(void (^)(NSSet *))completion
{
    [self.dataSource searchForParticipantsMatchingText:searchText completion:^(NSSet *participants) {
        completion (participants);
    }];
}

- (void)participantTableViewControllerDidSelectCancelButton
{
    [self.participantPickerDelegate participantSelectionViewControllerDidCancel:self];
}

- (void)participantTableViewControllerDidSelectDoneButtonWithSelectedParticipants:(NSMutableSet *)selectedParticipants
{
    [self.participantPickerDelegate participantSelectionViewController:self didSelectParticipants:selectedParticipants];
}

@end
