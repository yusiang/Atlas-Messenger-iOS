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
@property (nonatomic, strong) NSMutableSet *selectedParticipants;
@property (nonatomic, strong) LYRUIParticipantTableViewController *participantTableViewController;

@end

@implementation LYRUIParticipantPickerController

+ (instancetype)participantPickerWithParticipants:(id<LYRUIParticipantPickerDataSource>)dataSource sortType:(LYRUIParticipantPickerSortType)sortType
{
    return [[self alloc] initWithDataSource:dataSource sortType:sortType];
}

- (id)initWithDataSource:(id<LYRUIParticipantPickerDataSource>)dataSource sortType:(LYRUIParticipantPickerSortType)sortType
{
    self.participantTableViewController = [[LYRUIParticipantTableViewController alloc] init];
    
    self = [super initWithRootViewController:self.participantTableViewController];
    if (self) {
        
        self.participantPickerSortType = sortType;
        self.dataSource = dataSource;
        
        self.cellClass = [LYRUIParticipantTableViewCell class];
        self.allowsMultipleSelection = YES;
        
        self.participants = [self.dataSource participants];
        self.sortedParticipants = [self sortAndGroupContactListByAlphabet:self.participants];
        self.selectedParticipants = [NSMutableSet new];
        
        self.participantTableViewController.participants = _sortedParticipants;
        self.participantTableViewController.delegate = self;
    }
    return self;
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    self.participantTableViewController.allowsMultipleSelection = allowsMultipleSelection;
}

- (BOOL)allowsMultipleSelection
{
    return self.participantTableViewController.allowsMultipleSelection;
}

- (void)setCellClass:(Class<LYRUIParticipantPresenting>)cellClass
{
    self.participantTableViewController.participantCellClass = cellClass;
}

#pragma mark - Participant Table View Controller Delegate Methods

- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didSelectParticipant:(id<LYRUIParticipant>)participant
{
    if (self.allowsMultipleSelection) {
        if ([self.selectedParticipants containsObject:participant]) {
            [self.selectedParticipants removeObject:participant];
        } else {
            [self.selectedParticipants addObject:participant];
        }
    } else {
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

- (void)participantTableViewControllerDidSelectDoneButton
{
    [self.participantPickerDelegate participantSelectionViewController:self didSelectParticipants:self.selectedParticipants];
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
