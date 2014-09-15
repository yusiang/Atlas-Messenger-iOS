//
//  LYRUIConversationViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIConversationViewController.h"
#import "LYRUIOutgoingMessageCollectionViewCell.h"
#import "LYRUIIncomingMessageCollectionViewCell.h"
#import "LYRUIConversationCollectionViewHeader.h"
#import "LYRUIConversationCollectionViewFooter.h"
#import "LYRUIConstants.h"
#import "LYRUIUtilities.h"
#import "LYRUIChangeNotificationObserver.h"
#import "LYRUIConversationCollectionViewFlowLayout.h"
#import "LYRUIMessageBubbleView.h"

@interface LYRUIConversationViewController () <UICollectionViewDataSource, UICollectionViewDelegate, LYRUIComposeViewControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LYRUIChangeNotificationObserverDelegate>

@property (nonatomic, strong) LYRClient *layerClient;
@property (nonatomic, strong) LYRConversation *conversation;
@property (nonatomic, strong) NSOrderedSet *messages;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIViewController *inputToolbar;
@property (nonatomic, strong) LYRUIChangeNotificationObserver *changeNotificationObserver;
@property (nonatomic) BOOL keyboardIsOnScreen;
@property (nonatomic) CGFloat keyboardHeight;

@end

@implementation LYRUIConversationViewController

static NSString *const LYRUIIncomingMessageCellIdentifier = @"incomingMessageCellIdentifier";
static NSString *const LYRUIOutgoingMessageCellIdentifier = @"outgoingMessageCellIdentifier";

static NSString *const LYRUIMessageCellHeaderIdentifier = @"messageCellHeaderIdentifier";
static NSString *const LYRUIMessageCellFooterIdentifier = @"messageCellFooterIdentifier";

static NSString *const LSMessageHeaderIdentifier = @"headerViewIdentifier";
static CGFloat const LSComposeViewHeight = 40;
static CGFloat const LSMaxCellWidth = 240;

+ (instancetype)conversationViewControllerWithConversation:(LYRConversation *)conversation layerClient:(LYRClient *)layerClient;
{
    return [[self alloc] initWithConversation:conversation layerClient:layerClient];
}

- (id)initWithConversation:(LYRConversation *)conversation layerClient:(LYRClient *)layerClient
{
    self = [super init];
    if (self) {
        
        NSAssert(layerClient, @"`self.layerController` cannot be nil");
        NSAssert(conversation, @"`self.conversation` cannont be nil");
        
        self.title = @"Conversation";
        self.accessibilityLabel = @"Conversation";
        
        self.conversation = conversation;
        self.layerClient = layerClient;
    }
    return self;
}
    
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup Collection View
    //LYRUIConversationCollectionViewFlowLayout *layout = [[LYRUIConversationCollectionViewFlowLayout alloc] init];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                             collectionViewLayout:layout];
    
    self.collectionView.contentInset = self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 40, 0);
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = TRUE;
    self.collectionView.bounces = TRUE;
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.collectionView.accessibilityLabel = @"collectionView";
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[LYRUIIncomingMessageCollectionViewCell class] forCellWithReuseIdentifier:LYRUIIncomingMessageCellIdentifier];
    [self.collectionView registerClass:[LYRUIOutgoingMessageCollectionViewCell class] forCellWithReuseIdentifier:LYRUIOutgoingMessageCellIdentifier];
    [self.collectionView registerClass:[LYRUIConversationCollectionViewHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:LYRUIMessageCellHeaderIdentifier];
    [self.collectionView registerClass:[LYRUIConversationCollectionViewFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:LYRUIMessageCellFooterIdentifier];
    
    // Setup Compose View
    self.composeViewController = [[LYRUIComposeViewController alloc] init];
    self.composeViewController.delegate = self;
    self.composeViewController.view.frame = CGRectMake(0, self.view.bounds.size.height - LSComposeViewHeight, self.view.bounds.size.width, LSComposeViewHeight);
    [self.view addSubview:self.composeViewController.view];
    [self addChildViewController:self.composeViewController];
    [self.composeViewController didMoveToParentViewController:self];
    
    self.changeNotificationObserver = [[LYRUIChangeNotificationObserver alloc] initWithClient:self.layerClient conversations:@[self.conversation]];
    self.changeNotificationObserver.delegate = self;
    
    [self configureMessageBubbleAppearance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchMessages];
    [self.collectionView reloadData];
    [self scrollToBottomOfCollectionViewAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    self.keyboardIsOnScreen = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)fetchMessages
{
    NSAssert(self.conversation, @"Conversation should not be `nil`.");
    if (self.messages) self.messages = nil;
    self.messages = [self.layerClient messagesForConversation:self.conversation];
}

- (void)dealloc
{
    self.collectionView.delegate = nil;
}

# pragma mark
# pragma mark Collection View Data Source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[[self.messages objectAtIndex:section] parts] count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.messages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self.messages objectAtIndex:indexPath.section];
    LYRMessagePart *messagePart = [message.parts objectAtIndex:indexPath.row];
    
    LYRUIMessageCollectionViewCell <LYRUIMessagePresenting> *cell;
    if ([self.layerClient.authenticatedUserID isEqualToString:message.sentByUserID]) {
        cell =  [self.collectionView dequeueReusableCellWithReuseIdentifier:LYRUIOutgoingMessageCellIdentifier forIndexPath:indexPath];
    } else {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:LYRUIIncomingMessageCellIdentifier forIndexPath:indexPath];
    }
    [cell presentMessage:messagePart fromParticipant:nil];
    [cell updateBubbleViewWidth:[self sizeForItemAtIndexPath:indexPath].width];
    [self updateRecipientStatusForMessage:message];
    return cell;
}

- (void)updateRecipientStatusForMessage:(LYRMessage *)message
{
    NSNumber *recipientStatus = [message.recipientStatusByUserID objectForKey:self.layerClient.authenticatedUserID];
    if (![recipientStatus isEqualToNumber:[NSNumber numberWithInteger:LYRRecipientStatusRead]] ) {
        NSError *error;
        BOOL success = [self.layerClient markMessageAsRead:message error:&error];
        if (success) {
            NSLog(@"Message successfully marked as read");
        } else {
            NSLog(@"Failed to mark message as read with error %@", error);
        }
    }
}

#pragma mark
#pragma mark Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Nothing to do for now
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = [self sizeForItemAtIndexPath:indexPath];
    return CGSizeMake(rect.size.width, size.height);
}

- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self.messages objectAtIndex:indexPath.section];
    if (kind == UICollectionElementKindSectionHeader ) {
        LYRUIConversationCollectionViewHeader *header = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:LYRUIMessageCellHeaderIdentifier forIndexPath:indexPath];
        if ([self shouldDisplaySenderLabelForSection:indexPath.section]) {
            id<LYRUIParticipant>participant = [self.dataSource conversationViewController:self participantForIdentifier:message.sentByUserID];
            [header updateWithAttributedStringForParticipantName:participant.fullName];
        }
        
        if ([self shouldDisplayDateLabelForSection:indexPath.section]) {
            [header updateWithAttributedStringForDate:[self.dataSource conversationViewController:self attributedStringForDisplayOfDate:message.sentAt]];
        }
        return header;
    } else {
        LYRUIConversationCollectionViewFooter *footer = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:LYRUIMessageCellFooterIdentifier forIndexPath:indexPath];
        if ([self shouldDisplayReadReceiptForSection:indexPath.section]) {
            [footer updateWithAttributedStringForRecipientStatus:[self.dataSource conversationViewController:self attributedStringForDisplayOfRecipientStatus:message.recipientStatusByUserID]];
        }
        return footer;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if ([self shouldDisplayReadReceiptForSection:section]) {
        return CGSizeMake(320, 20);
    }
    return CGSizeMake(320, 4);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0;
    
    LYRMessage *message = [self.messages objectAtIndex:section];
    if (section > 0) {
        LYRMessage *previousMessage = [self.messages objectAtIndex:section - 1];
        if (![message.sentByUserID isEqualToString:previousMessage.sentByUserID]) {
            height += 10;
        }
    }
    
    if ([self shouldDisplayDateLabelForSection:section]) {
        height += 30;
    }
    
    if ([self shouldDisplaySenderLabelForSection:section]) {
        height += 30;
    }
    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, height);
}

- (BOOL)shouldDisplayDateLabelForSection:(NSUInteger)section
{
    // If it is the first section, show date label
    if (section == 0) return YES;
    
    LYRMessage *previousMessage;
    LYRMessage *message = [self.messages objectAtIndex:section];
    if (section > 0) {
        previousMessage = [self.messages objectAtIndex:section - 1];
    }
    double interval = [message.receivedAt timeIntervalSinceDate:previousMessage.receivedAt];
    
    // If it has been 60min since last message, show date label
    if (interval > (60 * 60)) {
        return YES;
    }
    
    // Otherwise, don't show date label
    return NO;
}

- (BOOL)shouldDisplaySenderLabelForSection:(NSUInteger)section
{
    LYRMessage *message = [self.messages objectAtIndex:section];
    if ([message.sentByUserID isEqualToString:self.layerClient.authenticatedUserID]) {
        return NO;
    }
    
    if (!self.conversation.participants.count > 2) {
        return NO;
    }
    
    if (section > 0) {
        LYRMessage *previousMessage = [self.messages objectAtIndex:section - 1];
        if ([previousMessage.sentByUserID isEqualToString:message.sentByUserID]) {
            return NO;
        }
    }

    return YES;
}

- (BOOL)shouldDisplayReadReceiptForSection:(NSUInteger)section
{
    LYRMessage *message = [self.messages objectAtIndex:section];
    if (section == self.messages.count - 1 && message.sentByUserID == self.layerClient.authenticatedUserID) {
        return YES;
    }
    return NO;
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self.messages objectAtIndex:indexPath.section];
    LYRMessagePart *part = [message.parts objectAtIndex:indexPath.row];
    
    CGSize size;
    if ([part.MIMEType isEqualToString:LYRUIMIMETypeTextPlain]) {
        NSString *text = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
        size = LYRUITextPlainSize(text, [[LYRUIOutgoingMessageCollectionViewCell appearance] messageTextFont]);
        size.height = size.height + 20; // Adding 16 to account for default vertical content inset with textView
    } else if ([part.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG] || [part.MIMEType isEqualToString:LYRUIMIMETypeImagePNG]) {
        UIImage *image = [UIImage imageWithData:part.data];
        size = LYRUIImageSize(image);
        size.height = size.height + 20;
    } else if ([part.MIMEType isEqualToString:LYRUIMIMETypeLocation]){
        size = CGSizeMake(240, 20);
    } else {
        //
    }
    return size;
}

#pragma mark
#pragma mark Keyboard Nofifications

- (void)keyboardWasShown:(NSNotification*)notification
{
    self.keyboardIsOnScreen = TRUE;
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.keyboardHeight = kbSize.height;
    [self updateInsets];
    
    self.composeViewController.view.frame = CGRectMake(self.composeViewController.view.frame.origin.x, self.composeViewController.view.frame.origin.y - kbSize.height, self.composeViewController.view.frame.size.width, self.composeViewController.view.frame.size.height);
    [self.collectionView setContentOffset:[self bottomOffset]];
    
    [UIView commitAnimations];
    
    self.keyboardIsOnScreen = TRUE;
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.keyboardHeight = 0;
    [self updateInsets];
    
    self.composeViewController.view.frame = CGRectMake(self.composeViewController.view.frame.origin.x, self.composeViewController.view.frame.origin.y + kbSize.height, self.composeViewController.view.frame.size.width, self.composeViewController.view.frame.size.height);
    [UIView commitAnimations];
    
    self.keyboardIsOnScreen = FALSE;
}

#pragma mark LYRUIComposeView Delegate Methods

- (void)composeViewController:(LYRUIComposeViewController *)composeViewController didTapRightAccessoryButton:(UIButton *)rightAccessoryButton
{
    if (composeViewController.messageContentParts) {
        [self sendMessageWithContentParts:composeViewController.messageContentParts];
    }
    if (self.composeViewController.textInputView.text.length > 1) {
        [self sendMessageWithText:composeViewController.textInputView.text];
    }
}

- (void)sendMessageWithContentParts:(NSMutableArray *)messageContentParts
{
    for (id object in messageContentParts){
        if ([object isKindOfClass:[UIImage class]]) {
            [self sendMessageWithImage:object];
        } else if ([object isKindOfClass:[CLLocation class]]) {
            [self sendMessageWithLocation:object];
        }
    }
}

- (void)sendMessageWithText:(NSString *)text
{
    LYRMessagePart *part = [LYRMessagePart messagePartWithText:text];
    LYRMessage *message = [LYRMessage messageWithConversation:self.conversation parts:@[ part ]];
    
    id<LYRUIParticipant>sender = [self.dataSource conversationViewController:self participantForIdentifier:self.layerClient.authenticatedUserID];
    NSString *pushText = [NSString stringWithFormat:@"%@: %@", [sender fullName], text];
    [self.layerClient setMetadata:@{LYRMessagePushNotificationAlertMessageKey: pushText} onObject:message];
    
    NSError *error;
    BOOL success = [self.layerClient sendMessage:message error:&error];
    if (success) {
        NSLog(@"Messages Succesfully Sent");
    } else {
        NSLog(@"The error is %@", error);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Messaging Error"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)sendMessageWithImage:(UIImage *)image
{
    UIImage *adjustedImage = LYRUIAdjustOrientationForImage(image);
    NSData *compressedImageData =  LYRUIJPEGDataForImageWithConstraint(adjustedImage, 300);
    
    LYRMessagePart *part = [LYRMessagePart messagePartWithMIMEType:LYRUIMIMETypeImageJPEG data:compressedImageData];
    LYRMessage *message = [LYRMessage messageWithConversation:self.conversation parts:@[ part ]];
    
    id<LYRUIParticipant>sender = [self.dataSource conversationViewController:self participantForIdentifier:self.layerClient.authenticatedUserID];
    NSString *pushText = [NSString stringWithFormat:@"%@: %@", [sender fullName], @"New Image"];
    [self.layerClient setMetadata:@{LYRMessagePushNotificationAlertMessageKey: pushText} onObject:message];
    
    NSError *error;
    BOOL success = [self.layerClient sendMessage:message error:&error];
    if (success) {
        NSLog(@"Messages Succesfully Sent");
    } else {
        NSLog(@"The error is %@", error);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Messaging Error"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)sendMessageWithLocation:(CLLocation *)location
{
    NSNumber *lat = [NSNumber numberWithDouble:location.coordinate.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:location.coordinate.longitude];
    NSDictionary *locationDictionary = @{@"lat" : lat,
                                         @"lon" : lon};
    LYRMessagePart *part = [LYRMessagePart messagePartWithMIMEType:LYRUIMIMETypeLocation data:[NSKeyedArchiver archivedDataWithRootObject:locationDictionary]];
    LYRMessage *message = [LYRMessage messageWithConversation:self.conversation parts:@[ part ]];
    
    id<LYRUIParticipant>sender = [self.dataSource conversationViewController:self participantForIdentifier:self.layerClient.authenticatedUserID];
    NSString *pushText = [NSString stringWithFormat:@"%@: %@", [sender fullName], @"New Location"];
    [self.layerClient setMetadata:@{LYRMessagePushNotificationAlertMessageKey: pushText} onObject:message];
    
    NSError *error;
    BOOL success = [self.layerClient sendMessage:message error:&error];
    if (success) {
        NSLog(@"Messages Succesfully Sent");
    } else {
        NSLog(@"The error is %@", error);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Messaging Error"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)composeViewController:(LYRUIComposeViewController *)composeViewController didTapLeftAccessoryButton:(UIButton *)leftAccessoryButton
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Choose Existing", @"Take Photo", nil];
    [actionSheet showInView:self.view];
}

#pragma mark
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self displayImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case 1:
            [self displayImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
            break;
        default:
            break;
    }
}

- (void)displayImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType;
{
    BOOL camera = [UIImagePickerController isSourceTypeAvailable:sourceType];
    
    if (camera) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = sourceType;
        [self.navigationController presentViewController:picker animated:YES completion:nil];
        NSLog(@"Camera is available");
    }
}

#pragma mark
#pragma mark Image Picker Controller Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:@"UIImagePickerControllerMediaType"];
    if ([mediaType isEqualToString:@"public.image"]) {
        
        // Get the selected image
        UIImage *selectedImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        
        [self.composeViewController insertImage:selectedImage];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Image Maniuplation Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark Notification Observer Delegate Methods

- (void) observerWillChangeContent:(LYRUIChangeNotificationObserver *)observer
{
    //nothing to do for now
}

- (void)observer:(LYRUIChangeNotificationObserver *)observer didChangeObject:(id)object atIndex:(NSUInteger)index forChangeType:(LYRObjectChangeType)changeType newIndexPath:(NSUInteger)newIndex
{
    if (changeType == LYRObjectChangeTypeCreate) {
        [self fetchMessages];
        [self.collectionView reloadData];
        [self scrollToBottomOfCollectionViewAnimated:TRUE];
    }
}

- (void) observerDidChangeContent:(LYRUIChangeNotificationObserver *)observer
{
    [self fetchMessages];
    [self.collectionView reloadData];
}

- (void)updateInsets
{
    UIEdgeInsets existing = self.collectionView.contentInset;
    self.collectionView.contentInset = self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(existing.top, 0, self.keyboardHeight + self.composeViewController.view.frame.size.height, 0);
}

- (CGPoint)bottomOffset
{
    return CGPointMake(0, MAX(-self.collectionView.contentInset.top, self.collectionView.collectionViewLayout.collectionViewContentSize.height - (self.collectionView.frame.size.height - self.collectionView.contentInset.bottom)));
    
}

- (void)scrollToBottomOfCollectionViewAnimated:(BOOL)animated
{
    if (self.messages.count > 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView setContentOffset:[self bottomOffset] animated:animated];
        });
    }
}

- (void)configureMessageBubbleAppearance
{
    [[LYRUIOutgoingMessageCollectionViewCell appearance] setMessageTextColor:[UIColor whiteColor]];
    [[LYRUIOutgoingMessageCollectionViewCell appearance] setMessageTextFont:LSMediumFont(14)];
    
    [[LYRUIIncomingMessageCollectionViewCell appearance] setMessageTextColor:[UIColor blackColor]];
    [[LYRUIIncomingMessageCollectionViewCell appearance] setMessageTextFont:LSMediumFont(14)];
}

@end
