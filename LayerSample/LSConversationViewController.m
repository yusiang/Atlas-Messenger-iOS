//
//  LSConversationViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSConversationViewController.h"
#import "LSSentMessageCell.h"
#import "LSRecievedMessageCell.h"
#import "LSComposeView.h"

@interface LSConversationViewController ()

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LSComposeView *composeView;
@property (nonatomic, strong) NSString *placeHolderUserID;

@end

@implementation LSConversationViewController

@synthesize collectionView = _collectionView;
@synthesize placeHolderUserID = _placeHolderUserID;

#define kSentMessageCellIdentifier         @"sentMessageCell"
#define kReceivedMessageCellIdentifier      @"receivedMessageCell"

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.placeHolderUserID = @"2";
    [self addCollectionView];
    [self addComposeView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.collectionView registerClass:[LSRecievedMessageCell class] forCellWithReuseIdentifier:kReceivedMessageCellIdentifier];
    [self.collectionView registerClass:[LSSentMessageCell class] forCellWithReuseIdentifier:kSentMessageCellIdentifier];
}

- (void) addComposeView
{
    self.composeView = [[LSComposeView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 48, self.view.frame.size.width, 48)];
    [self.view addSubview:self.composeView];
}

# pragma mark
# pragma mark Collection View Data Source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.conversation.messages.count;
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
    LYRSampleMessage *message = [self.conversation.messages objectAtIndex:indexPath.row];
    if ([message.sentByUserID isEqualToString:self.placeHolderUserID]) {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kSentMessageCellIdentifier forIndexPath:indexPath];
    } else {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kReceivedMessageCellIdentifier forIndexPath:indexPath];
    }
    [cell setMessageObject:[self.conversation.messages objectAtIndex:indexPath.row]];
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

@end
