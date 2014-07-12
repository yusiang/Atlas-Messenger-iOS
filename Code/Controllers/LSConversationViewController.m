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

NSData *LSJPEGDataWithData(NSData *data)
{
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 64*1024;
    
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

static NSString *const LSCMessageCellIdentifier = @"messageCellIdentifier";
static NSString *const LSMessagesUpdatedNotification = @"messagesUpdated";
static CGFloat const LSComposeViewHeight = 40;

@interface LSConversationViewController () <UICollectionViewDataSource, UICollectionViewDelegate, LSComposeViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LSComposeView *composeView;
@property (nonatomic, strong) NSOrderedSet *messages;
@property (nonatomic, strong) UIImage *selectedImage;

@end

@implementation LSConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSAssert(self.conversation, @"`self.conversation` cannont be nil");
    NSAssert(self.layerClient, @"`self.layerController` cannot be nil");
    
    self.title = @"Conversation";
    self.accessibilityLabel = @"Conversation";
    
    self.notificationObserver.delegate = self;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    // Setup Collection View
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 40)
                                             collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    self.collectionView.contentInset = UIEdgeInsetsMake(10, 0, 20, 0);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = TRUE;
    self.collectionView.bounces = TRUE;
    self.collectionView.accessibilityLabel = @"collectionView";
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[LSMessageCell class] forCellWithReuseIdentifier:LSCMessageCellIdentifier];
    
    // Setup Compose View
    self.composeView = [[LSComposeView alloc] initWithFrame:CGRectMake(0, rect.size.height - 40, rect.size.width, LSComposeViewHeight)];
    self.composeView.delegate = self;
    [self.view addSubview:self.composeView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerObjectsDidChangeNotification:) name:LYRClientObjectsDidChangeNotification object:self.layerClient];
}

- (void)didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification
{
    NSLog(@"Received notification: %@", notification);
    [self fetchMessages];
    [self.collectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchMessages];
    [self.collectionView reloadData];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messagesUpdated:) name:LSMessagesUpdatedNotification object:nil];
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
    NSOrderedSet *messages = [self.layerClient messagesForConversation:self.conversation];
    NSLog(@"Message Count %lu", (unsigned long)messages.count);
    self.messages = messages;
}

- (void)messagesUpdated:(NSNotification *)notification
{
    [self.collectionView reloadData];
    if (self.messages.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[[[self.messages lastObject] parts] count] - 1 inSection:self.messages.count - 1];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    }
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
    LSMessageCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:LSCMessageCellIdentifier forIndexPath:indexPath];
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
    LYRMessage *message = [self.messages objectAtIndex:section];
    LYRMessage *nextMessage;
    
    //If there is a next message....
    if (section > 0 && self.messages.count - 1 > section) {
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
    if ([self cellShouldShowSenderLabelForSection:section]) {
        return UIEdgeInsetsMake(20, 0, 0, 0);
    } else {
        return UIEdgeInsetsMake(6, 0, 0, 0);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
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
        [self fetchMessages];
        [self.collectionView reloadData];
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
        [self fetchMessages];
        [self.collectionView reloadData];
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

- (void)notificationObserver:(LSNotificationObserver *)observert didCreateMessage:(LYRMessage *)message
{
    if ([message.conversation isEqual:self.conversation]) {
        [self.collectionView reloadData];
    }
}

- (void)notificationObserver:(LSNotificationObserver *)observert didUpdateMessage:(LYRMessage *)message
{
    [self.collectionView reloadData];
}

- (void)notificationObserver:(LSNotificationObserver *)observert didDeleteMessage:(LYRMessage *)message
{
    [self.collectionView reloadData];
}



@end
