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
    [self.collectionView setContentSize:CGSizeMake(0, 60)];
    if (self.messages.count > 1) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    }
}

- (void)fetchMessages
{
    self.messages = [self.layerClient messagesForConversation:self.conversation];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSOrderedSet *set = [self.layerClient messagesForConversation:self.conversation];
        if (set.count > self.messages.count) {
             self.messages = set;
             if (self.messages.count > 1) {
                 [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
             }
         }
        [self.collectionView reloadData];
         [self fetchMessages];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"conversationsUpdated" object:nil userInfo:nil];
    });
}

# pragma mark
# pragma mark Collection View Data Source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LSMessageCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:LSCMessageCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(LSMessageCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    LSMessageCellPresenter *presenter = [[LSMessageCellPresenter alloc] init];
    presenter.persistenceManager = self.persistanceManager;
    presenter.message = [self.messages objectAtIndex:indexPath.row];
    [cell updateWithPresenter:presenter];
}

#pragma mark
#pragma mark Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self.messages objectAtIndex:indexPath.row];
    LYRMessagePart *part = [message.parts objectAtIndex:0];
    if ([part.MIMEType isEqualToString:LYRMIMETypeTextPlain]) {
        //
    } else if ([part.MIMEType isEqualToString:LYRMIMETypeImagePNG]) {
        //
    }
    
    //192 Is the width of the text view
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 192, 0)];
    textView.text = @"djsjsjdjdjdjdfhdsk";
    [textView sizeToFit];
    return CGSizeMake(320, 80);
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

- (void)sendMessageWithText:(NSString *)text
{
    LYRMessagePart *part = [LYRMessagePart messagePartWithText:text];
    LYRMessage *message = [self.layerClient messageWithConversation:self.conversation parts:@[ part ]];

    NSError *error;
    BOOL success = [self.layerClient sendMessage:message error:&error];
    if (success) {
        [self fetchMessages];
        [self.collectionView reloadData];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    } else {
        NSLog(@"The error is %@", error);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Messaging Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)sendMessageWithImage:(UIImage *)image
{
    LYRMessagePart *part = [LYRMessagePart messagePartWithMIMEType:LYRMIMETypeImagePNG data:UIImagePNGRepresentation(image)];
    LYRMessage *message = [self.layerClient messageWithConversation:self.conversation parts:@[ part ]];
    
    NSError *error;
    BOOL success = [self.layerClient sendMessage:message error:&error];
    if (success) {
        [self fetchMessages];
        [self.collectionView reloadData];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    } else {
        NSLog(@"The error is %@", error);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Messaging Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
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
