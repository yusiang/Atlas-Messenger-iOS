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

@interface LSConversationViewController () <UICollectionViewDataSource, UICollectionViewDelegate, LSComposeViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LSComposeView *composeView;
@property (nonatomic, strong) NSOrderedSet *messages;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation LSConversationViewController

static NSString *const LSCMessageCellIdentifier = @"messageCellIdentifier";

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSAssert(self.conversation, @"`self.conversation` cannont be nil");
    NSAssert(self.layerClient, @"`self.layerController` cannot be nil");
    
    self.title = @"Conversation";
    self.accessibilityLabel = @"Conversation";
    
    // Setup Collection View
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 48)
                                             collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = TRUE;
    self.collectionView.bounces = TRUE;
    self.collectionView.accessibilityLabel = @"collectionView";
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[LSMessageCell class] forCellWithReuseIdentifier:LSCMessageCellIdentifier];
    
    // Setup Compose View
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.composeView = [[LSComposeView alloc] initWithFrame:CGRectMake(0, rect.size.height - 48, rect.size.width, 48)];
    self.composeView.delegate = self;
    [self.view addSubview:self.composeView];
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messagesUpdated:) name:@"messagesUpdated" object:nil];
    
    //[self.dataSource cellClass:class withIdentifier:identifier];
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
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    }
}

- (void)fetchMessages
{
    if (self.navigationController.topViewController == self) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSOrderedSet *newMessages = [self.layerClient messagesForConversation:self.conversation];
            NSLog(@"New Message Count %lu", (unsigned long)newMessages.count);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"messagesUpdated" object:nil userInfo:nil];
            [self fetchMessages];
        });
    }
    
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
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionBottom
                                            animated:YES];
    }
}

# pragma mark
# pragma mark Collection View Data Source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //[self.dataSource numberOfItemsInSection:section];
    return self.messages.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //[self.dataSource numberOfSectionsInCollectionView:section];
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //[self.dataSource cellForItemAtIndexPath:indexPath];
    LSMessageCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:LSCMessageCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(LSMessageCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    //[self.dataSource messageForCellAtIndex:indexPath];
    LSMessageCellPresenter *presenter = [LSMessageCellPresenter presenterWithMessage:[self.messages objectAtIndex:indexPath.row] persistanceManager:self.persistanceManager];
    [cell updateWithPresenter:presenter];
}

#pragma mark
#pragma mark Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //[self.delegate didSelectItemAtIndexPath];
    //Nothing to do for now
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self.messages objectAtIndex:indexPath.row];
    LYRMessagePart *part = [message.parts objectAtIndex:0];
    if ([part.MIMEType isEqualToString:LYRMIMETypeTextPlain]) {
        
        //192 Is the width of the text view
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 180, 0)];
        textView.text = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
        [textView sizeToFit];
        return CGSizeMake(320, textView.frame.size.height + 24);
    } else if ([part.MIMEType isEqualToString:LYRMIMETypeImagePNG]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:part.data]];
        if (imageView.frame.size.height > imageView.frame.size.width) {
            return CGSizeMake(320, 300);
        } else {
            CGFloat ratio = (184 / imageView.frame.size.width);
            CGFloat height = imageView.frame.size.height * ratio;
            return CGSizeMake(320, height + 8);
        }
    }
    return CGSizeMake(320, 10);
}

- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 48, 0);
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
    //[self.delegate conversationViewController:self didSendMessageWithText:text]
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
    //[self.delegate conversationViewController:self didSendImage:image]
    LYRMessagePart *part = [LYRMessagePart messagePartWithMIMEType:LYRMIMETypeImagePNG data:[self compressedImageWithData:UIImagePNGRepresentation(image)]];
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
}

- (NSData *)compressedImageWithData:(NSData *)imageData
{
    
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 64*1024;
    
    UIImage *image = [UIImage imageWithData:imageData];
    
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    return imageData;
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
        self.selectedImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        [self.composeView updateWithImage:self.selectedImage];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
