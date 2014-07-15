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
#import "LSUtilities.h"

CGSize LSItemSizeForPart(LYRMessagePart *part, CGFloat width)
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize itemSize;
    
    //If Message Part is plain text...
    if ([part.MIMEType isEqualToString:LYRMIMETypeTextPlain]) {
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, width * 0.70, 0)];
        textView.text = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
        textView.font = LSMediumFont(14);
        [textView sizeToFit];
        itemSize = CGSizeMake(rect.size.width, textView.frame.size.height);
    }
   
    //If Message Part is an image...
    if ([part.MIMEType isEqualToString:LYRMIMETypeImagePNG] || [part.MIMEType isEqualToString:@"image/jpeg"]) {
        UIImage *image = [UIImage imageWithData:part.data];
        UIImage *imageToDisplay = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:UIImageOrientationRight];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:imageToDisplay];

        if (imageView.frame.size.height > imageView.frame.size.width) {
            itemSize = CGSizeMake(rect.size.width, 300);
        } else {
            CGFloat ratio = ((rect.size.width * .75) / imageView.frame.size.width);
            itemSize = CGSizeMake(rect.size.width, imageView.frame.size.height * ratio);
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

@interface LSBlockOperation : NSOperation

- (void)addExecutionBlock:(void (^)(void))block;

@end

@interface LSBlockOperation ()

@property (nonatomic) NSMutableArray *executionBlocks;

@end

@implementation LSBlockOperation

- (id)init
{
    self = [super init];
    if (self) {
        _executionBlocks = [NSMutableArray new];
    }
    return self;
}

- (void)addExecutionBlock:(void (^)(void))block
{
    [self.executionBlocks addObject:[block copy]];
}

- (void)main
{
    for (void (^executionBlock)(void) in self.executionBlocks) {
        executionBlock();
    }
}

@end


@interface LSConversationViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, LSComposeViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LSNotificationObserverDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LSComposeView *composeView;
@property (nonatomic, strong) NSOrderedSet *messages;
@property (nonatomic, strong) LSNotificationObserver *observer;
@property (nonatomic, strong) NSMutableArray *collectionViewUpdates;
@property (nonatomic) LSBlockOperation *blockOperation;
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchMessages];
    [self.collectionView reloadData];
    [self scrollToBottomOfCollectionView];
    if (!LSIsRunningTests()) {
        self.notificationObserver = [[LSNotificationObserver alloc] initWithClient:self.layerClient conversations:@[self.conversation]];
        self.notificationObserver.delegate = self;
    }
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
    [self scrollToBottomOfCollectionView];
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
    LSMessageCellPresenter *presenter = [LSMessageCellPresenter presenterWithMessages:self.messages indexPath:indexPath persistanceManager:self.persistanceManager];
    [self updateRecipientStatusForMessage:presenter.message];
    [cell updateWithPresenter:presenter];
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
        LSMessageCellPresenter *presenter = [LSMessageCellPresenter presenterWithMessages:self.messages indexPath:indexPath persistanceManager:self.persistanceManager];
        if ([presenter shouldShowSenderLabel] && [presenter shouldShowTimeStamp]) {
            [header updateWithSenderName:[presenter labelForMessageSender] timeStamp:presenter.message.sentAt];
        } else if ([presenter shouldShowSenderLabel]) {
            [header updateWithSenderName:[presenter labelForMessageSender] timeStamp:nil];
        } else if ([presenter shouldShowTimeStamp]) {
            [header updateWithSenderName:nil timeStamp:presenter.message.receivedAt];
        }
    }
    return header;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    LSMessageCellPresenter *presenter = [LSMessageCellPresenter presenterWithMessages:self.messages indexPath:[NSIndexPath indexPathForItem:0 inSection:section] persistanceManager:self.persistanceManager];
    if ([presenter shouldShowSenderLabel] && [presenter shouldShowTimeStamp]) {
        return CGSizeMake(bounds.size.width, 60);
    } else if ([presenter shouldShowSenderLabel]) {
        return CGSizeMake(bounds.size.width, 40);
    } else if ([presenter shouldShowTimeStamp]) {
        return CGSizeMake(bounds.size.width, 40);
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

# pragma mark
# pragma mark Cell UI Configuration Methods
- (void)updateRecipientStatusForMessage:(LYRMessage *)message
{
    NSString *identifier = self.APImanager.authenticatedSession.user.userID;
    LYRRecipientStatus status = [message recipientStatusForUserID:identifier];
    if (status == LYRRecipientStatusDelivered) {
        [self.layerClient markMessageAsRead:message];
    }
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"sentAt"]) {
        NSLog(@"Message sent");
    }
}

- (void)composeView:(LSComposeView *)composeView sendMessageWithImage:(UIImage *)image
{
    NSData *imageData = UIImagePNGRepresentation(image);
    UIImage *compressedImage = [self jpegDataForImage:[[UIImage imageWithData:imageData] CGImage] constraint:300];
    NSData *compressedImageData = UIImageJPEGRepresentation(compressedImage, 0.25f);
    
    LYRMessagePart *part = [LYRMessagePart messagePartWithMIMEType:LYRMIMETypeImagePNG data:compressedImageData];
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

// Photo JPEG Compression
- (UIImage *)jpegDataForImage:(CGImageRef)image constraint:(CGFloat)constraint
{
    CGFloat width = 1.0f * CGImageGetWidth(image);
    CGFloat height = 1.0f * CGImageGetHeight(image);
    CGSize previousSize = CGSizeMake(width, height);
    CGSize newSize = [self sizeFromOriginalSize:previousSize withMaxConstraint:constraint];
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    UIImage *assetImage = [UIImage imageWithCGImage:image];
    [assetImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    return UIGraphicsGetImageFromCurrentImageContext();
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
        UIImage *selectedImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        NSLog (@"User did select image %@", selectedImage);
        [self.composeView updateWithImage:selectedImage];
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
    self.blockOperation = [LSBlockOperation new];
}

- (void)observer:(LSNotificationObserver *)observer didChangeObject:(id)object atIndex:(NSUInteger)index forChangeType:(LYRObjectChangeType)changeType newIndexPath:(NSUInteger)newIndex
{
    __weak typeof(self) weakSelf = self;
    if ([object isKindOfClass:[LYRMessage class]]) {
        switch (changeType) {
            case LYRObjectChangeTypeCreate: {
                [self.blockOperation addExecutionBlock:^{
                    [weakSelf.collectionView insertSections:[NSIndexSet indexSetWithIndex:newIndex]];
                    if(newIndex > 0) [weakSelf.collectionView reloadSections:[NSIndexSet indexSetWithIndex:newIndex - 1]];
                }];
            }
            break;
            case LYRObjectChangeTypeUpdate: {
                [self.blockOperation addExecutionBlock:^{
                    [weakSelf.collectionView reloadSections:[NSIndexSet indexSetWithIndex:index]];
                }];
            }
            break;
            case LYRObjectChangeTypeDelete: {
                [self.blockOperation addExecutionBlock:^{
                    [weakSelf.collectionView deleteSections:[NSIndexSet indexSetWithIndex:index]];
                }];
            }
            break;
            default:
                break;
        }
    }
}

- (void) observerDidChangeContent:(LSNotificationObserver *)observer
{
    [self.collectionView performBatchUpdates:^{
        [self.blockOperation  start];
        [self fetchMessages];
        [[self.collectionView collectionViewLayout] invalidateLayout];
        [self scrollToBottomOfCollectionView];
    } completion:nil];
    self.blockOperation = nil;
}

- (void)scrollToBottomOfCollectionView
{
    if (self.messages.count > 1) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:self.collectionView.numberOfSections - 1] atScrollPosition:UICollectionViewScrollPositionBottom animated:TRUE];
    }
}

@end
