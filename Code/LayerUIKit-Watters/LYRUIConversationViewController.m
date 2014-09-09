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
#import "LYRUIConstants.h"
#import "LYRUIUtilities.h"

@interface LYRUIConversationViewController () <UICollectionViewDataSource, UICollectionViewDelegate, LYRUIComposeViewControllerDelegate>

@property (nonatomic, strong) LYRClient *layerClient;
@property (nonatomic, strong) LYRConversation *conversation;
@property (nonatomic, strong) NSOrderedSet *messages;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIViewController *inputToolbar;
@property (nonatomic) BOOL keyboardIsOnScreen;

@end

@implementation LYRUIConversationViewController

static NSString *const LYRUIIncomingMessageCellIdentifier = @"incomingMessageCellIdentifier";
static NSString *const LYRUIOutgoingMessageCellIdentifier = @"outgoingMessageCellIdentifier";

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
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                             collectionViewLayout:flowLayout];
    
    self.collectionView.contentInset = self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 40, 0);
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = TRUE;
    self.collectionView.bounces = TRUE;
    self.collectionView.accessibilityLabel = @"collectionView";
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[LYRUIIncomingMessageCollectionViewCell class] forCellWithReuseIdentifier:LYRUIIncomingMessageCellIdentifier];
    [self.collectionView registerClass:[LYRUIOutgoingMessageCollectionViewCell class] forCellWithReuseIdentifier:LYRUIOutgoingMessageCellIdentifier];
    //[self.collectionView registerClass:[LSMessageCellHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:LSMessageHeaderIdentifier];
    
    // Setup Compose View
    self.composeViewController = [[LYRUIComposeViewController alloc] init];
    self.composeViewController.delegate = self;
    self.composeViewController.view.frame = CGRectMake(0, self.view.bounds.size.height - LSComposeViewHeight, self.view.bounds.size.width, LSComposeViewHeight);
    [self.view addSubview:self.composeViewController.view];
    [self addChildViewController:self.composeViewController];
    [self.composeViewController didMoveToParentViewController:self];
    
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
    return cell;
}


- (void)markMessageAtIndexPathAsRead:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self.messages objectAtIndex:indexPath.section];
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
    CGFloat itemHeight;
    
    LYRMessage *message = [self.messages objectAtIndex:indexPath.section];
    LYRMessagePart *part = [message.parts objectAtIndex:indexPath.row];
    
    if ([part.MIMEType isEqualToString:LYRMIMETypeTextPlain]) {
        NSString *text = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
        CGSize size = LYRUITextPlainSize(text, LSMediumFont(12));
        itemHeight = size.height + 16;
    } else if ([part.MIMEType isEqualToString:LYRMIMETypeImageJPEG] || [part.MIMEType isEqualToString:LYRMIMETypeImagePNG]) {
        UIImage *image = [UIImage imageWithData:part.data];
        CGSize size = LYRUIImageSize(image, rect);
        itemHeight = size.height + 16;
    } else if ([part.MIMEType isEqualToString:LYRMIMETypeLocation]){
        itemHeight = 200;
    } else {
        itemHeight = 200;
    }
     
    return CGSizeMake(rect.size.width, itemHeight);
}

- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return [[UICollectionReusableView alloc] init];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(320, 20);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

# pragma mark
# pragma mark Cell UI Configuration Methods
//- (void)updateRecipientStatusForMessage:(LYRMessage *)message
//{
//    NSString *identifier = self.APImanager.authenticatedSession.user.userID;
//    LYRRecipientStatus status = [message recipientStatusForUserID:identifier];
//    if (status == LYRRecipientStatusDelivered) {
//        [self.layerClient markMessageAsRead:message error:nil];
//    }
//}

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
    
//    self.keyboardHeight = kbSize.height;
    //[self updateInsets];
    
    //self.composeView.frame = CGRectMake(self.composeView.frame.origin.x, self.composeView.frame.origin.y - kbSize.height, self.composeView.frame.size.width, self.composeView.frame.size.height);
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
    
    //self.keyboardHeight = 0;
    //[self updateInsets];
    
    //self.composeView.frame = CGRectMake(self.composeView.frame.origin.x, self.composeView.frame.origin.y + kbSize.height, self.composeView.frame.size.width, self.composeView.frame.size.height);
    [UIView commitAnimations];
    
    self.keyboardIsOnScreen = FALSE;
    //[self composeViewShouldRestFrame:nil];
}

#pragma mark
#pragma mark LSComposeViewDelegate

//- (void)composeView:(LSComposeView *)composeView sendMessageWithText:(NSString *)text
//{
//    LYRMessagePart *part = [LYRMessagePart messagePartWithText:text];
//    LYRMessage *message = [LYRMessage messageWithConversation:self.conversation parts:@[ part ]];
//    
//    NSString *senderName = [self.persistanceManager persistedSessionWithError:nil].user.fullName;
//    NSString *pushText = [NSString stringWithFormat:@"%@: %@", senderName, text];
//    [self.layerClient setMetadata:@{LYRMessagePushNotificationAlertMessageKey: pushText} onObject:message];
//    
//    NSError *error;
//    BOOL success = [self.layerClient sendMessage:message error:&error];
//    if (success) {
//        NSLog(@"Messages Succesfully Sent");
//    } else {
//        NSLog(@"The error is %@", error);
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Messaging Error"
//                                                            message:[error localizedDescription]
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//        [alertView show];
//    }
//}
//
//- (void)composeViewShouldRestFrame:(LSComposeView *)composeView
//{
//    if (!self.keyboardIsOnScreen) {
//        CGRect rect = [[UIScreen mainScreen] bounds];
//        [self.composeView setFrame:CGRectMake(0, rect.size.height - 40, rect.size.width, 40)];
//    }
//}
//
//- (void)composeView:(LSComposeView *)composeView setComposeViewHeight:(CGFloat)height
//{
//    if (height < 135 && height != self.composeView.frame.size.height) {
//        CGFloat yOriginOffset = composeView.frame.size.height - height;
//        [self.composeView setFrame:CGRectMake(0, composeView.frame.origin.y + yOriginOffset, self.view.frame.size.width, height)];
//        [self updateInsets];
//        [self scrollToBottomOfCollectionViewAnimated:YES];
//    }
//}
//
//- (void)composeView:(LSComposeView *)composeView sendMessageWithImage:(UIImage *)image
//{
//    UIImage *adjustedImage = [self adjustOrientationForImage:image];;
//    NSData *compressedImageData = [self jpegDataForImage:adjustedImage constraint:300];
//    
//    LYRMessagePart *part = [LYRMessagePart messagePartWithMIMEType:MIMETypeImageJPEG() data:compressedImageData];
//    LYRMessage *message = [LYRMessage messageWithConversation:self.conversation parts:@[ part ]];
//    
//    NSString *senderName = [self.persistanceManager persistedSessionWithError:nil].user.fullName;
//    NSString *pushText = [NSString stringWithFormat:@"%@: Sent you a photo!", senderName];
//    [self.layerClient setMetadata:@{LYRMessagePushNotificationAlertMessageKey: pushText} onObject:message];
//    
//    NSError *error;
//    BOOL success = [self.layerClient sendMessage:message error:&error];
//    if (success) {
//        NSLog(@"Picture Message Succesfully Sent");
//    } else {
//        NSLog(@"The error is %@", error);
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Messaging Error"
//                                                            message:[error localizedDescription]
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//        [alertView show];
//    }
//    
//}

- (UIImage *)adjustOrientationForImage:(UIImage *)originalImage
{
    UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, originalImage.scale);
    [originalImage drawInRect:(CGRect){0, 0, originalImage.size}];
    UIImage *fixedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return fixedImage;
}

// Photo JPEG Compression
- (NSData *)jpegDataForImage:(UIImage *)image constraint:(CGFloat)constraint
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    CGImageRef ref = [[UIImage imageWithData:imageData] CGImage];
    
    CGFloat width = 1.0f * CGImageGetWidth(ref);
    CGFloat height = 1.0f * CGImageGetHeight(ref);
    
    CGSize previousSize = CGSizeMake(width, height);
    CGSize newSize = [self sizeFromOriginalSize:previousSize withMaxConstraint:constraint];
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    UIImage *assetImage = [UIImage imageWithCGImage:ref];
    [assetImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *imageToCompress = UIGraphicsGetImageFromCurrentImageContext();
    
    return UIImageJPEGRepresentation(imageToCompress, 0.25f);
}

// Photo Resizing
- (CGSize)sizeFromOriginalSize:(CGSize)originalSize withMaxConstraint:(CGFloat)constraint
{
    if (originalSize.height > constraint && (originalSize.height > originalSize.width)) {
        CGFloat heightRatio = constraint / originalSize.height;
        return CGSizeMake(originalSize.width * heightRatio, constraint);
    } else if (originalSize.width > constraint) {
        CGFloat widthRatio = constraint / originalSize.width;
        return CGSizeMake(constraint, originalSize.height * widthRatio);
    }
    return originalSize;
}

//- (void)composeViewDidTapCamera:(LSComposeView *)composeView
//{
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]
//                                  initWithTitle:nil
//                                  delegate:self
//                                  cancelButtonTitle:@"Cancel"
//                                  destructiveButtonTitle:nil
//                                  otherButtonTitles:@"Choose Existing", @"Take Photo", nil];
//    [actionSheet showInView:self.view];
//}
//
//- (void)composeView:(LSComposeView *)composeView shouldChangeHeightForLines:(double)lines
//{
//    //TODO:Implement functionality to grow text input view height to accomodate for multiple lines
//}
//
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
        [self.navigationController presentViewController:picker animated:YES completion:^{
            //
        }];
        NSLog(@"Camera is available");
    }
}

#pragma mark
#pragma mark Image Picker Controller Delegate

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    NSString *mediaType = [info objectForKey:@"UIImagePickerControllerMediaType"];
//    if ([mediaType isEqualToString:@"public.image"]) {
//        
//        // Get the selected image
//        UIImage *selectedImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
//        
//        //Get the rect we would like to display with a max height fo 120
//        CGRect imageRect = LSImageRectForThumb(selectedImage.size, 120);
//        
//        //Resize the compose view frame with the image
//        CGRect frame = self.composeView.frame;
//        frame.size.height = imageRect.size.height + 20;
//        frame.origin.y = self.view.frame.size.height - frame.size.height;
//        self.composeView.frame = frame;
//        
//        [self.composeView updateWithImage:selectedImage];
//    }
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark Notification Observer Delegate Methods

//- (void) observerWillChangeContent:(LSNotificationObserver *)observer
//{
//    //nothing to do for now
//}
//
//- (void)observer:(LSNotificationObserver *)observer didChangeObject:(id)object atIndex:(NSUInteger)index forChangeType:(LYRObjectChangeType)changeType newIndexPath:(NSUInteger)newIndex
//{
//    //Nothing to do for now
//}
//
//- (void) observerDidChangeContent:(LSNotificationObserver *)observer
//{
//    [self fetchMessages];
//    [self.collectionView reloadData];
//    [self scrollToBottomOfCollectionViewAnimated:YES];
//}

//- (void)updateInsets
//{
//    UIEdgeInsets existing = self.collectionView.contentInset;
//    self.collectionView.contentInset = self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(existing.top, 0, self.keyboardHeight + self.composeView.frame.size.height, 0);
//}

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
    [[LYRUIOutgoingMessageCollectionViewCell appearance] setMessageTextFont:LSMediumFont(12)];
    
    [[LYRUIIncomingMessageCollectionViewCell appearance] setMessageTextColor:[UIColor blackColor]];
    [[LYRUIIncomingMessageCollectionViewCell appearance] setMessageTextFont:LSMediumFont(12)];
}
@end
