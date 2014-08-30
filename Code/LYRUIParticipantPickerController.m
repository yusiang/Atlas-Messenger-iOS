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

+ (instancetype)participantPickerWithParticipants:(NSSet *)participants
{
    return [[self alloc] initWithParticipants:participants];
}

- (id)initWithParticipants:(NSSet *)participants
{
    self.participantTableViewController = [[LYRUIParticipantTableViewController alloc] init];
    
    self = [super initWithRootViewController:self.participantTableViewController];
    if (self) {
        
        _participants = participants;
        
        _sortedParticipants = [self sortAndGroupContactListByAlphabet:participants];
        
        self.participantTableViewController.delegate = self;
        self.participantTableViewController.participants = _sortedParticipants;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    self.participantTableViewController.tableView.allowsMultipleSelection = allowsMultipleSelection;
}

- (BOOL)allowsMultipleSelection
{
    return self.participantTableViewController.tableView.allowsMultipleSelection;
}

#pragma mark - Participant Table View Controller Delegate Methods

- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didSelectParticipant:(id<LYRUIParticipant>)participant
{
    if (!self.allowsMultipleSelection) {
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
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"(fullName like[cd] %@)", [NSString stringWithFormat:@"*%@*", searchText]];
    NSSet *filteredParticipants = [self.participants filteredSetUsingPredicate:searchPredicate];
    completion ([self sortAndGroupContactListByAlphabet:filteredParticipants]);
    
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
    NSArray *sortedParticipants = [[participants allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES]]];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (id<LYRUIParticipant>participant in sortedParticipants) {
        NSString *firstName = participant.firstName;
        NSString *firstLetter = [[firstName substringToIndex:1] uppercaseString];
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
