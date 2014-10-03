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

@interface LSConversationDetailViewController () <LYRUIParticipantPickerDataSource>

@property (nonatomic) LYRConversation *conversation;
@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) LSUIParticipantPickerDataSource *participantPickerDataSource;

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.participantPickerDataSource = [LSUIParticipantPickerDataSource participantPickerDataSourceWithPersistenceManager:self.applicationContoller.persistenceManager];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[LYRUIParticipantTableViewCell class] forCellReuseIdentifier:LYRUIParticipantCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:LYRUIParticipantInviteCellIdentifier];
    [self configureAppearance];
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
        cell.textLabel.font = [UIFont systemFontOfSize:14];
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
    return 20;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.conversation.participants.count) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Feature Not Implemented"
                                                            message:@"Tell Kevin To Fix It"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)configureAppearance
{
    [[LYRUIParticipantTableViewCell appearance] setTitleColor:[UIColor blackColor]];
    [[LYRUIParticipantTableViewCell appearance] setTitleFont:[UIFont systemFontOfSize:14]];
}


@end


