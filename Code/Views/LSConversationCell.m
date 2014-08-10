//
//  LSConversationViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSConversationCell.h"
#import "LSAvatarImageView.h"
#import "LSUIConstants.h"
#import "LSUser.h"
#import "LSUtilities.h"

@interface LSConversationCell ()

@property (nonatomic) LSAvatarImageView *avatarImageView;
@property (nonatomic) UILabel *senderLabel;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UITextView *lastMessageTextView;

@end

@implementation LSConversationCell

// Cell Constants
static CGFloat const LSCellTopMargin = 12.0f;
static CGFloat const LSCellHorizontalMargin = 12.0f;
static CGFloat const LSCellBottomMargin = 10.0f;

// Avatart Constants
static CGFloat const LSAvatarImageViewSizeRatio  = 0.60f;

// Sender Label Constants
static CGFloat const LSCellSenderLabelRightMargin = -68.0f;

// Date Label Constants
static CGFloat const LSCellDateLabelLeftMargin = 2.0f;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        // Initialize Avatar Image
        self.avatarImageView = [[LSAvatarImageView alloc] init];
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.avatarImageView];
       
        // Initialiaze Sender Image
        self.senderLabel = [[UILabel alloc] init];
        self.senderLabel.font = LSMediumFont(14);
        self.senderLabel.textColor = [UIColor blackColor];
        self.senderLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.senderLabel];
        
        // Initialize Message Text
        self.lastMessageTextView = [[UITextView alloc] init];
        self.lastMessageTextView.contentInset = UIEdgeInsetsMake(-4,-4,0,0);
        self.lastMessageTextView.translatesAutoresizingMaskIntoConstraints = NO;
        self.lastMessageTextView.userInteractionEnabled = NO;
        self.lastMessageTextView.font = LSMediumFont(12);
        self.lastMessageTextView.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.lastMessageTextView];

        // Initialize Date Label
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.textAlignment= NSTextAlignmentRight;
        self.dateLabel.font = LSMediumFont(12);
        self.dateLabel.textColor = [UIColor darkGrayColor];
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.dateLabel];
        
        [self setupConstraints];
    }
    return self;
}

- (void)updateWithPresenter:(LSConversationCellPresenter *)presenter
{
    // Set Sender Label
    self.senderLabel.text = presenter.conversationLabel;
    self.accessibilityLabel = presenter.conversationLabel;
    
    // Set Last Message Text 
    LYRMessage *message = presenter.message;
    LYRMessagePart *part = [message.parts firstObject];
    
    if ([part.MIMEType isEqualToString:MIMETypeTextPlain()]) {
        self.lastMessageTextView.text = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
        [self.lastMessageTextView setFont:LSMediumFont(12)];
    } else if ([part.MIMEType isEqualToString:MIMETypeImagePNG()]) {
        self.lastMessageTextView.text = @"Attachemnt: Image";
    } else if ([part.MIMEType isEqualToString:MIMETypeImageJPEG()]) {
        self.lastMessageTextView.text = @"Attachemnt: Image";
    } else {
        self.lastMessageTextView.text = @"DRAFT CONVERSATION: No Text!";
    }
    
    // Set Date Text
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned int conversationDateFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents* conversationDateComponents = [calendar components:conversationDateFlags fromDate:presenter.conversation.lastMessage.sentAt];
    NSDate *conversationDate = [calendar dateFromComponents:conversationDateComponents];
    
    unsigned int currentDateFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents* currentDateComponents = [calendar components:currentDateFlags fromDate:[NSDate date]];
    NSDate *currentDate = [calendar dateFromComponents:currentDateComponents];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([conversationDate compare:currentDate] == NSOrderedAscending) {
        [formatter setDateFormat:@"MMM dd"];
    } else {
        [formatter setDateFormat:@"hh:mm a"];
    }
    self.dateLabel.text = [formatter stringFromDate:presenter.conversation.lastMessage.sentAt];
}

#pragma mark
#pragma mark Layout Code
- (void)setupConstraints
{
    //**********Avatar Constraints**********//
    // Width
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.contentView
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:LSAvatarImageViewSizeRatio
                                                           constant:0]];
    
    // Height
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.contentView
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:LSAvatarImageViewSizeRatio
                                                           constant:0]];
    
    // Left Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.contentView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:LSCellHorizontalMargin]];
    
    // Center vertically
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.contentView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0]];
    
    //**********Sender Label Test Constraints**********//
    // Left Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.senderLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:LSCellHorizontalMargin]];
    // Right Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.senderLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:LSCellSenderLabelRightMargin]];
    // Top Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.senderLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:LSCellTopMargin]];
    // Height
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.senderLabel
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:0.25
                                                                  constant:0]];
    
    //**********Message Text Constraints**********//
    //Left Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:LSCellHorizontalMargin]];
    // Right Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:-LSCellHorizontalMargin]];
    // Top Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.senderLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0]];
    // Bottom Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:-LSCellBottomMargin]];
    
    //**********Date Label Constraints**********//
    // Left Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.senderLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:LSCellDateLabelLeftMargin]];
    // Right Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:-10]];
    // Height
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.senderLabel
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:1.0
                                                                  constant:0]];
    // Top Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:LSCellTopMargin]];
}

- (void)updateConstraints
{
    [super updateConstraints];
    self.avatarImageView.layer.cornerRadius = (LSAvatarImageViewSizeRatio * self.frame.size.height) / 2;
    self.avatarImageView.clipsToBounds = YES;
}

@end
