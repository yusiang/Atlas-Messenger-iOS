//
//  LSMessageDetailTableViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 11/3/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSMessageDetailTableViewController.h"

typedef NS_ENUM(NSInteger, LSMessageDetailTableSection) {
    LSMessageDetailTableSectionMetadata,
    LSMessageDetailTableSectionRecipientStatus,
    LSMessageDetailTableSectionCount,
};

typedef NS_ENUM(NSInteger, LSMessageMetadataTableRow) {
    LSMessageMetadataTableRowParts,
    LSMessageMetadataTableRowSentAt,
    LSMessageMetadataTableRowReceivedAt,
    LSMessageMetadataTableRowIsSent,
    LSMessageMetadataTableRowIsDeleted,
    LSMessageMetadataTableRowSentBy,
    LSMessageMetadataTableRowCount,
};

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
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:LSMessageDetailCell];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(doneButtonTapped)];
    doneButton.accessibilityLabel = @"Done";
    [self.navigationItem setRightBarButtonItem:doneButton];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return LSMessageDetailTableSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch ((LSMessageDetailTableSection)section) {
        case LSMessageDetailTableSectionMetadata:
            return LSMessageMetadataTableRowCount;
            
        case LSMessageDetailTableSectionRecipientStatus:
            return self.message.recipientStatusByUserID.count;
            
        case LSMessageDetailTableSectionCount:
            return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LSMessageDetailCell];
    UILabel *messagesLabel = [[UILabel alloc] init];
    
    NSArray *recipients = [self.message.recipientStatusByUserID allKeys];
    
    switch ((LSMessageDetailTableSection)indexPath.section) {
        case LSMessageDetailTableSectionMetadata:
            switch ((LSMessageMetadataTableRow)indexPath.row) {
                case LSMessageMetadataTableRowParts:
                    cell.textLabel.text = [NSString stringWithFormat:@"Number of Parts:"];
                    messagesLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.message.parts.count];
                    messagesLabel.font = cell.textLabel.font;
                    [messagesLabel sizeToFit];
                    cell.accessoryView = messagesLabel;
                    break;

                case LSMessageMetadataTableRowSentAt:
                    cell.textLabel.text = [NSString stringWithFormat:@"Sent At:"];
                    messagesLabel.text = [self.dateFormatter stringFromDate:self.message.sentAt];
                    messagesLabel.font = cell.textLabel.font;
                    [messagesLabel sizeToFit];
                    cell.accessoryView = messagesLabel;
                    break;
                
                case LSMessageMetadataTableRowReceivedAt:
                    cell.textLabel.text = [NSString stringWithFormat:@"Received At:"];
                    messagesLabel.text = [self.dateFormatter stringFromDate:self.message.receivedAt];
                    messagesLabel.font = cell.textLabel.font;
                    [messagesLabel sizeToFit];
                    cell.accessoryView = messagesLabel;
                    break;
                    
                case LSMessageMetadataTableRowIsSent:
                    cell.textLabel.text = [NSString stringWithFormat:@"Is Sent:"];
                    messagesLabel.text = (self.message.isSent) ? @"Yes" : @"No";
                    messagesLabel.font = cell.textLabel.font;
                    [messagesLabel sizeToFit];
                    cell.accessoryView = messagesLabel;
                    break;
                    
                case LSMessageMetadataTableRowIsDeleted:
                    cell.textLabel.text = [NSString stringWithFormat:@"Is Deleted:"];
                    messagesLabel.text = (self.message.isDeleted) ? @"Yes" : @"No";
                    messagesLabel.font = cell.textLabel.font;
                    [messagesLabel sizeToFit];
                    cell.accessoryView = messagesLabel;
                    break;
                    
                case LSMessageMetadataTableRowSentBy:
                    cell.textLabel.text = [NSString stringWithFormat:@"Sent By:"];
                    messagesLabel.text = [self recipientNameForUserID:self.message.sentByUserID];
                    messagesLabel.font = cell.textLabel.font;
                    [messagesLabel sizeToFit];
                    cell.accessoryView = messagesLabel;
                    break;
                    
                case LSMessageMetadataTableRowCount:
                    break;
            }
            break;
        case LSMessageDetailTableSectionRecipientStatus:
            cell.textLabel.text = [self recipientNameForUserID:[recipients objectAtIndex:indexPath.row]];
            messagesLabel.text = [self recipientStateForUserID:[recipients objectAtIndex:indexPath.row]];
            messagesLabel.font = cell.textLabel.font;
            [messagesLabel sizeToFit];
            cell.accessoryView = messagesLabel;
            break;

        case LSMessageDetailTableSectionCount:
            break;
    }
    
    return cell;
}

- (NSString *)recipientNameForUserID:(NSString *)userID
{
    LSUser *user = [self.applicationController.persistenceManager userForIdentifier:userID];
    return user.fullName;
}

- (NSString *)recipientStateForUserID:(NSString *)userID
{
    switch ([self.message recipientStatusForUserID:userID]) {
        case LYRRecipientStatusSent:
            return @"Sent";
            
        case LYRRecipientStatusDelivered:
            return @"Delivered";
            
        case LYRRecipientStatusRead:
            return @"Read";
            
        case LYRRecipientStatusInvalid:
            return @"Invalid";
            
        default:
            return nil;
    }
}

- (void)doneButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
