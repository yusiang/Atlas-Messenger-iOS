//
//  LSConversationViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSConversationViewController.h"
#import "LSMessageCell.h"
#import "LSMessageCellPresenter.h"
#import "LSComposeView.h"
#import "LSUIConstants.h"
#import "LSMessageCellHeader.h"

NSData *LSJPEGDataWithData(NSData *data)
{
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 30*1024;
    
    UIImage *image = [UIImage imageWithData:data];
    
    while ([data length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        data = UIImageJPEGRepresentation(image, compression);
    }
    return data;
}

CGSize LSItemSizeForPart(LYRMessagePart *part, CGFloat width)
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize itemSize;
    
    //If Message Part is plain text...
    if ([part.MIMEType isEqualToString:LYRMIMETypeTextPlain]) {
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, width * 0.50, 0)];
        textView.text = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
        textView.font = LSMediumFont(14);
        [textView sizeToFit];
        itemSize = CGSizeMake(rect.size.width, textView.frame.size.height);
    }
   
    //If Message Part is an image...
    if ([part.MIMEType isEqualToString:LYRMIMETypeImagePNG]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:part.data]];
        if (imageView.frame.size.height > imageView.frame.size.width) {
            itemSize = CGSizeMake(rect.size.width, 300);
        } else {
            CGFloat ratio = ((rect.size.width - 136) / imageView.frame.size.width);
            CGFloat height = imageView.frame.size.height * ratio;
            itemSize = CGSizeMake(rect.size.width, height + 8);
        }
    }
    
    if ([part.MIMEType isEqualToString:@"image/jpeg"]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:part.data]];
        if (imageView.frame.size.height > imageView.frame.size.width) {
            itemSize = CGSizeMake(rect.size.width, 300);
        } else {
            CGFloat ratio = ((rect.size.width - 136) / imageView.frame.size.width);
            CGFloat height = imageView.frame.size.height * ratio;
            itemSize = CGSizeMake(rect.size.width, height + 8);
        }
    }
    
    if (30 > itemSize.height) {
        itemSize = CGSizeMake(itemSize.width, 30);
    }
    
    return itemSize;
}


static NSString *const LSMessageCellIdentifier = @"messageCellIdentifier";
static NSString *const LSMessageHeaderIdentifier = @"headerViewIdentifier";
static CGFloat const LSComposeViewHeight = 40;

@interface LSConversationViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, LSComposeViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LSNotificationObserverDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LSComposeView *composeView;
@property (nonatomic, strong) NSOrderedSet *messages;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) LSNotificationObserver *observer;
@property (nonatomic, strong) NSMutableArray *collectionViewUpdates;

@end

@implementation LSConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSAssert(self.conversation, @"`self.conversation` cannont be nil");
    NSAssert(self.layerClient, @"`self.layerController` cannot be nil");
    
    self.title = @"Conversation";
    self.accessibilityLabel = @"Conversation";
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    // Setup Collection View
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//    flowLayout.headerReferenceSize = CGSizeMake(self.collectionView.frame.size.width, 100.f);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 40)
                                             collectionViewLayout:flowLayout];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(10, 0, 20, 0);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = TRUE;
    self.collectionView.bounces = TRUE;
    self.collectionView.accessibilityLabel = @"collectionView";
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[LSMessageCell class] forCellWithReuseIdentifier:LSMessageCellIdentifier];
    [self.collectionView registerClass:[LSMessageCellHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:LSMessageHeaderIdentifier];
    
    // Setup Compose View
    self.composeView = [[LSComposeView alloc] initWithFrame:CGRectMake(0, rect.size.height - 40, rect.size.width, LSComposeViewHeight)];
    self.composeView.delegate = self;
    [self.view addSubview:self.composeView];
    
    self.notificationObserver = [[LSNotificationObserver alloc] initWithClient:self.layerClient conversation:self.conversation];
    self.notificationObserver.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchMessages];
    [self scrollToBottomOfCollectionView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.messages.count > 1) {
         NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[[[self.messages lastObject] parts] count] - 1 inSection:self.messages.count - 1];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    }
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)fetchMessages
{
    NSAssert(self.conversation, @"Conversation should not be `nil`.");
    if (self.messages) self.messages = nil;
    self.messages = [self.layerClient messagesForConversation:self.conversation];
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
    LSMessageCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:LSMessageCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(LSMessageCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    LSMessageCellPresenter *presenter = [LSMessageCellPresenter presenterWithMessage:[self.messages objectAtIndex:indexPath.section]
                                                                           indexPath:indexPath
                                                                  persistanceManager:self.persistanceManager];
    presenter.shouldShowSenderImage = [self cellShouldShowSenderImageForSection:indexPath.section];
    [cell updateWithPresenter:presenter];
}

- (BOOL)cellShouldShowSenderImageForSection:(NSUInteger)section
{
    LYRMessage *message = [self.messages objectAtIndex:section];
    LYRMessage *previousMessage;
    
    //If there is a previous message...
    if (self.messages.count > 0 && self.messages.count - 1 > section) {
        previousMessage = [self.messages objectAtIndex:(section + 1)];
    }
    
    //Check if it was sent by the same user as the current message
    if ([previousMessage.sentByUserID isEqualToString:message.sentByUserID]) {
        return NO;
    } else {
        return YES;
        
    }
}

- (BOOL)cellShouldShowSenderLabelForSection:(NSUInteger)section
{
    if (!self.conversation.participants.count > 2) return FALSE;
    
    if (section == 0 ) return TRUE;
    
    LYRMessage *message = [self.messages objectAtIndex:section];
    LYRMessage *nextMessage;
    
    //If there is a next message....
    if (section > 0 && self.messages.count - 1 >= section) {
        nextMessage = [self.messages objectAtIndex:(section - 1)];
    } else {
        return NO;
    }
    
    //Check if it was sent by the same user as the current message
    if ([nextMessage.sentByUserID isEqualToString:message.sentByUserID]) {
        return NO;
    } else {
        return YES;
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
    LYRMessage *message = [self.messages objectAtIndex:indexPath.section];
    LYRMessagePart *part = [message.parts objectAtIndex:indexPath.row];
    return LSItemSizeForPart(part, self.view.frame.size.width);
}

- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 6, 0);
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
    LSMessageCellHeader *header = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:LSMessageHeaderIdentifier forIndexPath:indexPath];
    if (kind == UICollectionElementKindSectionHeader ) {
        LSMessageCellPresenter *presenter = [LSMessageCellPresenter presenterWithMessage:[self.messages objectAtIndex:indexPath.section]
                                                                               indexPath:indexPath
                                                                      persistanceManager:self.persistanceManager];
        if (!presenter.messageWasSentByAuthenticatedUser) {
            [header updateWithSenderName:[presenter labelForMessageSender]];
        }
    }
    return header;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    if ([self cellShouldShowSenderLabelForSection:section]) {
        return CGSizeMake(bounds.size.width, 32);
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

#pragma mark
#pragma mark Keyboard Nofifications

- (void)keyboardWasShown:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y + kbSize.height)];
        self.composeView.frame = CGRectMake(self.composeView.frame.origin.x, self.composeView.frame.origin.y - kbSize.height, self.composeView.frame.size.width, self.composeView.frame.size.height);
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y - kbSize.height)];
        self.composeView.frame = CGRectMake(self.composeView.frame.origin.x, self.composeView.frame.origin.y + kbSize.height, self.composeView.frame.size.width, self.composeView.frame.size.height);
    } completion:^(BOOL finished) {
        //
    }];
}

#pragma mark
#pragma mark LSComposeViewDelegate

- (void)composeView:(LSComposeView *)composeView sendMessageWithText:(NSString *)text
{
    LYRMessagePart *part = [LYRMessagePart messagePartWithText:text];
    LYRMessage *message = [self.layerClient messageWithConversation:self.conversation parts:@[ part ]];

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

- (void)composeView:(LSComposeView *)composeView sendMessageWithImage:(UIImage *)image
{
    LYRMessagePart *part = [LYRMessagePart messagePartWithMIMEType:LYRMIMETypeImagePNG data:LSJPEGDataWithData(UIImagePNGRepresentation(image))];
    LYRMessage *message = [self.layerClient messageWithConversation:self.conversation parts:@[ part ]];
    
    NSError *error;
    BOOL success = [self.layerClient sendMessage:message error:&error];
    if (success) {
        NSLog(@"Picture Message Succesfully Sent");
    } else {
        NSLog(@"The error is %@", error);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Messaging Error"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    CGRect rect = [[UIScreen mainScreen] bounds];
    [UIView animateWithDuration:0.2 animations:^{
        self.composeView.frame = CGRectMake(0, rect.size.height - 40, rect.size.width, 40);
    }];
}

- (void)cameraTapped
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Choose Existing", @"Take Photo", nil];
    [actionSheet showInView:self.view];
}

- (void)composeView:(LSComposeView *)composeView shouldChangeHeightForLines:(double)lines
{
    //TODO:Implement functionality to grow text input view height to accomodate for multiple lines
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
        [self.navigationController presentViewController:picker animated:YES completion:^{
            //
        }];
        NSLog(@"Camera is available");
    }
}

#pragma mark
#pragma mark Image Picker Controller Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:@"UIImagePickerControllerMediaType"];
    if ([mediaType isEqualToString:@"public.image"]) {
        CGRect frame = self.composeView.frame;
        frame.size.height = 120;
        frame.origin.y = self.view.frame.size.height - 120;
        self.composeView.frame = frame;
        self.selectedImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        [self.composeView updateWithImage:self.selectedImage];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark Notification Observer Delegate

#pragma mark
#pragma mark Notification Observer Delegate Methods

- (void) observerWillChangeContent:(LSNotificationObserver *)observer
{
    //
}

- (void)observer:(LSNotificationObserver *)observer didChangeObject:(id)object atIndex:(NSUInteger)index forChangeType:(LYRObjectChangeType)changeType newIndexPath:(NSUInteger)newIndex
{
    [self fetchMessages];
    
    if ([object isKindOfClass:[LYRMessage class]]) {
        LYRMessage *message = object;
        switch (changeType) {
            case LYRObjectChangeTypeCreate:
                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:self.messages.count - 1]];
                break;
            case LYRObjectChangeTypeUpdate:
                for (int i = 0; i < message.parts.count; i++) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:self.messages.count - 1];
                    [self configureCell:(LSMessageCell *)[self.collectionView cellForItemAtIndexPath:indexPath] forIndexPath:indexPath];
                }
                break;
            case LYRObjectChangeTypeDelete:
                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:index]];
                break;
            default:
                break;
        }
    }
}

- (void) observerDidChangeContent:(LSNotificationObserver *)observer
{
    [self scrollToBottomOfCollectionView];
}

- (void)scrollToBottomOfCollectionView
{
    if (self.messages.count > 1) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:self.messages.count - 1] atScrollPosition:UICollectionViewScrollPositionBottom animated:TRUE];
    }
}



@end
