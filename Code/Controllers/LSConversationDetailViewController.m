//
//  LYRUIConversationDetailViewController.m
//  Pods
//
//  Created by Kevin Coleman on 10/2/14.
//
//

#import "LSConversationDetailViewController.h"
#import "LYRUIParticipantTableViewCell.h"
#import "LYRUIConstants.h"
#import "LYRUISelectionIndicator.h"
#import "LYRUIParticipantPickerController.h"
#import "LSUIParticipantPickerDataSource.h"
#import "LSUtilities.h"
#import "LYRUIConversationDataSource.h"
#import "LSDetailHeaderView.h"

@interface LSConversationDetailViewController () <LYRUIParticipantPickerDataSource, LYRUIParticipantPickerControllerDelegate, LYRUIConversationDataSourceDelegate>

@property (nonatomic) LYRConversation *conversation;
@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) LSUIParticipantPickerDataSource *participantPickerDataSource;
@property (nonatomic) LYRUIConversationDataSource *conversationDataSource;
@end

@implementation LSConversationDetailViewController

static NSString *const LYRUIParticipantCellIdentifier = @"participantCell";
static NSString *const LYRUIParticipantInviteCellIdentifier = @"participantInviteCellIdentifier";

+ (instancetype)conversationDetailViewControllerLayerClient:(LYRClient *)layerClient conversation:(LYRConversation *)conversation
{
    return [[self alloc] initWithLayerClient:layerClient conversation:conversation];
}

- (id)initWithLayerClient:(LYRClient *)layerClient conversation:(LYRConversation *)conversation
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _layerClient = layerClient;
        _conversation = conversation;
        _conversationDataSource = [[LYRUIConversationDataSource alloc] initWithLayerClient:self.layerClient];
        _conversationDataSource.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.participantPickerDataSource = [LSUIParticipantPickerDataSource participantPickerDataSourceWithPersistenceManager:self.applicationController.persistenceManager];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[LYRUIParticipantTableViewCell class] forCellReuseIdentifier:LYRUIParticipantCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:LYRUIParticipantInviteCellIdentifier];
    [self configureAppearance];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tableView.delegate = nil;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.conversation.participants.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row > self.conversation.participants.count - 1 ) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:LYRUIParticipantInviteCellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"+ Add Participant";
        cell.textLabel.textColor = LSBlueColor();
        cell.textLabel.font = LSMediumFont(14);
    } else {
        NSString *participantIdentifier = [[self.conversation.participants allObjects] objectAtIndex:indexPath.row];
        id<LYRUIParticipant>participant = [self.detailDelegate conversationDetailViewController:self participantForIdentifier:participantIdentifier];
        UITableViewCell <LYRUIParticipantPresenting> *participantCell = [self.tableView dequeueReusableCellWithIdentifier:LYRUIParticipantCellIdentifier forIndexPath:indexPath];
        [participantCell presentParticipant:participant];
        [participantCell shouldDisplaySelectionIndicator:NO];
        cell = participantCell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [LSDetailHeaderView initWithTitle:@"Details"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.conversation.participants.count) {
        LYRUIParticipantPickerController *controller = [LYRUIParticipantPickerController participantPickerWithDataSource:self.participantPickerDataSource
                                                                                                                sortType:LYRUIParticipantPickerControllerSortTypeFirst];
        controller.participantPickerDelegate = self;
        controller.allowsMultipleSelection = YES;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *particpantID = [[self.conversation.participants allObjects] objectAtIndex:indexPath.row];
        [self.applicationController.layerClient removeParticipants:[NSSet setWithObject:particpantID] fromConversation:self.conversation error:nil];
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView reloadData];
}


- (void)participantSelectionViewControllerDidCancel:(LYRUIParticipantPickerController *)participantSelectionViewController
{
    [self dismissViewControllerAnimated:TRUE completion:^{
        //
    }];
}

- (void)participantSelectionViewController:(LYRUIParticipantPickerController *)participantSelectionViewController didSelectParticipants:(NSSet *)participants
{
    [self dismissViewControllerAnimated:TRUE completion:^{
        NSSet *participantIdentifiers = [participants valueForKey:@"userID"];
        NSError *error;
        [self.layerClient addParticipants:participantIdentifiers toConversation:self.conversation error:&error];
    }];
}

- (void)observer:(LYRUIConversationDataSource *)observer updateWithChanges:(NSArray *)changes
{
    [self.tableView reloadData];
}

- (void)observer:(LYRUIConversationDataSource *)observer didChangeContent:(BOOL)didChangeContent
{
    //
}

- (void)configureAppearance
{
    [[LYRUIParticipantTableViewCell appearance] setTitleColor:[UIColor blackColor]];
    [[LYRUIParticipantTableViewCell appearance] setTitleFont:LSMediumFont(14)];
}


@end


