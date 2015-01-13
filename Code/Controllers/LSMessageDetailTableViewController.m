//
//  LSMessageDetailTableViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 11/3/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSMessageDetailTableViewController.h"

@interface LSMessageDetailTableViewController ()

@property (nonatomic) LSApplicationController *applicationController;
@property (nonatomic) LYRMessage *message;
@property (nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation LSMessageDetailTableViewController

static NSString *const LSMessageDetailCell = @"messageDetailCell";

+ (instancetype)messageDetailTableViewControllerWithMessage:(LYRMessage *)message applicationController:(LSApplicationController *)applicationController
{
    return [[self alloc] initWithMessage:message applicationController:applicationController];
}

- (id)initWithMessage:(LYRMessage *)message applicationController:(LSApplicationController *)applicationController
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _applicationController = applicationController;
        _message = message;
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        _dateFormatter.doesRelativeDateFormatting = YES;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"Message Detail";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:LSMessageDetailCell];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(doneButtonTapped)];
    doneButton.accessibilityLabel = @"Done";
    [self.navigationItem setRightBarButtonItem:doneButton];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 6;
            break;
            
        case 1:
            return self.message.recipientStatusByUserID.count;
            break;
            
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LSMessageDetailCell];
    UILabel *messagesLabel = [[UILabel alloc] init];
    
    NSArray *recipients = [self.message.recipientStatusByUserID allKeys];
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = [NSString stringWithFormat:@"Number of Parts:"];
                    messagesLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.message.parts.count];
                    messagesLabel.font = cell.textLabel.font;
                    [messagesLabel sizeToFit];
                    cell.accessoryView = messagesLabel;
                    break;

                case 1:
                    cell.textLabel.text = [NSString stringWithFormat:@"Sent At:"];
                    messagesLabel.text = [self.dateFormatter stringFromDate:self.message.sentAt];
                    messagesLabel.font = cell.textLabel.font;
                    [messagesLabel sizeToFit];
                    cell.accessoryView = messagesLabel;
                    break;
                
                case 2:
                    cell.textLabel.text = [NSString stringWithFormat:@"Received At:"];
                    messagesLabel.text = [self.dateFormatter stringFromDate:self.message.receivedAt];
                    messagesLabel.font = cell.textLabel.font;
                    [messagesLabel sizeToFit];
                    cell.accessoryView = messagesLabel;
                    break;
                    
                case 3:
                    cell.textLabel.text = [NSString stringWithFormat:@"Is Sent:"];
                    messagesLabel.text = (self.message.isSent) ? @"Yes" : @"No";
                    messagesLabel.font = cell.textLabel.font;
                    [messagesLabel sizeToFit];
                    cell.accessoryView = messagesLabel;
                    break;
                    
                case 4:
                    cell.textLabel.text = [NSString stringWithFormat:@"Is Deleted:"];
                    messagesLabel.text = (self.message.isDeleted) ? @"Yes" : @"No";
                    messagesLabel.font = cell.textLabel.font;
                    [messagesLabel sizeToFit];
                    cell.accessoryView = messagesLabel;
                    break;
                    
                case 5:
                    cell.textLabel.text = [NSString stringWithFormat:@"Sent By:"];
                    messagesLabel.text = [self recipientNameForUserId:self.message.sentByUserID];
                    messagesLabel.font = cell.textLabel.font;
                    [messagesLabel sizeToFit];
                    cell.accessoryView = messagesLabel;
                    break;
                    
                default:
                    break;
            }
            break;
        case 1:
            cell.textLabel.text = [self recipientNameForUserId:[recipients objectAtIndex:indexPath.row]];
            messagesLabel.text = [self recipientStateForUserID:[recipients objectAtIndex:indexPath.row]];
            messagesLabel.font = cell.textLabel.font;
            [messagesLabel sizeToFit];
            cell.accessoryView = messagesLabel;
            break;

        default:
            break;
    }
    
    return cell;
}

- (NSString *)recipientNameForUserId:(NSString *)userID
{
    LSUser *user = [self.applicationController.persistenceManager userForIdentifier:userID];
    return user.fullName;
}

- (NSString *)recipientStateForUserID:(NSString *)userID
{
    switch ([self.message recipientStatusForUserID:userID]) {
        case LYRRecipientStatusSent:
            return @"Sent";
            break;
            
        case LYRRecipientStatusDelivered:
            return @"Delivered";
            break;
            
        case LYRRecipientStatusRead:
            return @"Read";
            break;
            
        case LYRRecipientStatusInvalid:
            return @"Invalid";
            break;
            
        default:
            break;
    }
}

- (void)doneButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
