//
//  LSConversationViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSConversationViewController.h"
#import "LSMessageCell.h"

@interface LSConversationViewController ()

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LSComposeView *composeView;
@property (nonatomic, strong) NSOrderedSet *messages;
@property (nonatomic, strong) UIImage *selectedImage;

@end

@implementation LSConversationViewController

#define kMessageCellIdentifier         @"messageCell"

- (id) init
{
    self = [super init];
    if(self) {
        self.view.backgroundColor = [UIColor lightGrayColor];
        self.title = @"Chat";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Chat";
    if (!self.conversation) [self createConversation];
    [self fetchLayerConversations];
    [self setAccessibilityLabel:@"chat"];
    [self addCollectionView];
    [self addComposeView];
    [self registerForKeyboardNotifications];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.composeView.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) createConversation
{
    LYRConversation *conversation = [self.layerController.client conversationWithIdentifier:@"1" participants:@[@"100101"]];
    self.conversation = conversation;
}

- (void) fetchLayerConversations
{
    self.messages = [self.layerController.client messagesForConversation:self.conversation];
}

- (void)addCollectionView
{
    if (!self.collectionView) {
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame
                                                 collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.collectionView];
    }
    [self.collectionView registerClass:[LSMessageCell class] forCellWithReuseIdentifier:kMessageCellIdentifier];
}

- (void) addComposeView
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.composeView = [[LSComposeView alloc] initWithFrame:CGRectMake(0, rect.size.height - 48, rect.size.width, 48)];
    self.composeView.delegate = self;
    [self.view addSubview:self.composeView];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

# pragma mark
# pragma mark Collection View Data Source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //return self.messages.count;
    return self.messages.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LSMessageCell *cell = [[LSMessageCell alloc] init];
    cell = [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (LSMessageCell *)configureCell:(LSMessageCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self.messages objectAtIndex:indexPath.row];
    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kMessageCellIdentifier forIndexPath:indexPath];
    [cell updateCellWithMessage:message andLayerController:self.layerController];
    [cell setAccessibilityLabel:@"Message Cell"];
    return cell;
}

#pragma mark
#pragma mark Collection View Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(320, 80);
}

- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark
#pragma mark Keyboard Nofifications

-(void)keyboardWasShown:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
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
        self.composeView.frame = CGRectMake(self.composeView.frame.origin.x, self.composeView.frame.origin.y + kbSize.height, self.composeView.frame.size.width, self.composeView.frame.size.height);
    } completion:^(BOOL finished) {
        //
    }];
}

#pragma mark
#pragma mark LSComposeViewDelegate

-(void)sendMessageWithText:(NSString *)text
{
    [self.layerController sendMessage:text inConversation:self.conversation];
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
        
        // Since I'm not actually taking a picture, is a delegate function necessary?
        picker.delegate = self;
        
        picker.sourceType = sourceType;
        [self.navigationController presentViewController:picker animated:TRUE completion:^{
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
    [self.navigationController dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:TRUE completion:nil];
}


@end
