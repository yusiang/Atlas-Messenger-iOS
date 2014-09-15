//
//  LYRUIParticipantPickerController.m
//  
//
//  Created by Kevin Coleman on 8/29/14.
//
//

#import "LYRUIParticipantPickerController.h"
#import "LYRUIParticipantTableViewController.h"

@interface LYRUIParticipantPickerController () <LYRUIParticipantTableViewControllerDelegate>

@property (nonatomic, strong) NSSet *participants;
@property (nonatomic, strong) NSDictionary *sortedParticipants;
@property (nonatomic, strong) LYRUIParticipantTableViewController *participantTableViewController;
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
    self.participantTableViewController = [[LYRUIParticipantTableViewController alloc] init];
    self.participantTableViewController.delegate = self;
    
    self = [super initWithRootViewController:self.participantTableViewController];
    if (self) {
        
        // Set properties from designated initializer
        self.dataSource = dataSource;
        self.participantPickerSortType = sortType;

        // Set default configuration for public properties
        [self setAllowsMultipleSelection:YES];
        [self setCellClass:[LYRUIParticipantTableViewCell class]];
        [self setRowHeight:48];
        
        // Accessibility
        self.title = @"Participants";
        self.accessibilityLabel = @"Participants";
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    self.participants = [self.dataSource participants];
    self.sortedParticipants = [self sortAndGroupContactListByAlphabet:self.participants];
    self.participantTableViewController.participants = self.sortedParticipants;
    
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
    if (!self.allowsMultipleSelection) {
        [self.participantPickerDelegate participantSelectionViewController:self didSelectParticipants:[NSSet setWithObject:participant]];
    }
}

- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didSearchWithString:(NSString *)searchText completion:(void (^)(NSDictionary *))completion
{
    [self.dataSource searchForParticipantsMatchingText:searchText completion:^(NSSet *participants) {
        completion ([self sortAndGroupContactListByAlphabet:participants]);
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

- (NSDictionary *)sortAndGroupContactListByAlphabet:(NSSet *)participants
{
    NSArray *sortedParticipants;
    
    switch (self.participantPickerSortType) {
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
        switch (self.participantPickerSortType) {
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

@end
