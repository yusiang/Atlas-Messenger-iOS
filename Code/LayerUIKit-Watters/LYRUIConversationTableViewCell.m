//
//  LYRUIConversationTableViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIConversationTableViewCell.h"
#import "LYRUIAvatarImageView.h"
#import "LSUIConstants.h"

@interface LYRUIConversationTableViewCell ()

@property (nonatomic) LYRUIAvatarImageView *avatarImageView;
@property (nonatomic) UILabel *senderLabel;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UITextView *lastMessageTextView;
@property (nonatomic) BOOL shouldShowAvatarImage;

@property (nonatomic) CGFloat senderLabelHeight;
@property (nonatomic) CGFloat dateLabelHeight;
@property (nonatomic) CGFloat cellHorizontalMargin;
@end

@implementation LYRUIConversationTableViewCell

// Cell Constants
static CGFloat const LSCellVerticalMargin = 12.0f;

// Avatart Constants
static CGFloat const LSAvatarImageViewSizeRatio  = 0.60f;

// Sender Label Constants
static CGFloat const LSCellSenderLabelRightMargin = -68.0f;

// Date Label Constants
static CGFloat const LSCellDateLabelLeftMargin = 0.0f;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        if (!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
        }
        
        // Initialiaze Sender Image
        self.senderLabel = [[UILabel alloc] init];
        self.senderLabel.font = self.titleFont;
        self.senderLabel.textColor = self.titleColor;
        self.senderLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.senderLabel];
        
        // Initialize Message Text
        self.lastMessageTextView = [[UITextView alloc] init];
        self.lastMessageTextView.contentInset = UIEdgeInsetsMake(-4,-4,0,0);
        self.lastMessageTextView.translatesAutoresizingMaskIntoConstraints = NO;
        self.lastMessageTextView.userInteractionEnabled = NO;
        self.lastMessageTextView.font = self.subtitleFont;
        self.lastMessageTextView.textColor = self.subtitleColor;
        [self.contentView addSubview:self.lastMessageTextView];
        
        // Initialize Date Label
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.textAlignment= NSTextAlignmentRight;
        self.dateLabel.font = LSMediumFont(12);
        self.dateLabel.textColor = [UIColor darkGrayColor];
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.dateLabel];
        
        self.cellHorizontalMargin = 20.0f;
    }
    return self;
}

- (void)presentConversation:(LYRConversation *)conversation withLabel:(NSString *)conversationLabel
{
    self.senderLabel.text = conversationLabel;
    self.dateLabel.text = [self dateLabelForLastMessage:conversation.lastMessage];
    
    LYRMessage *message = conversation.lastMessage;
    LYRMessagePart *messagePart = [message.parts objectAtIndex:0];
    if (messagePart) {
        self.lastMessageTextView.text = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    } else if (messagePart.MIMEType == LYRUIMIMETypeImageJPEG) {
        self.lastMessageTextView.text = @"Attachement: Image";
    } else if (messagePart.MIMEType == LYRUIMIMETypeImagePNG) {
        self.lastMessageTextView.text = @"Attachement: Image";
    } else if (messagePart.MIMEType == LYRUIMIMETypeLocation) {
        self.lastMessageTextView.text = @"Attachement: Location";
    }
   
    [self configureLayoutConstraintsForLabels];
    [self updateConstraints];
}

static NSDateFormatter *dateFormatter;

- (NSString *)dateLabelForLastMessage:(LYRMessage *)lastMessage
{
    if (!lastMessage) {
        return @"";
    }
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned int conversationDateFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents* conversationDateComponents = [calendar components:conversationDateFlags fromDate:lastMessage.sentAt];
    NSDate *conversationDate = [calendar dateFromComponents:conversationDateComponents];
    
    unsigned int currentDateFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents* currentDateComponents = [calendar components:currentDateFlags fromDate:[NSDate date]];
    NSDate *currentDate = [calendar dateFromComponents:currentDateComponents];
    
    if ([conversationDate compare:currentDate] == NSOrderedAscending) {
        [dateFormatter setDateFormat:@"MMM dd"];
    } else {
        [dateFormatter setDateFormat:@"hh:mm a"];
    }
    NSString *dateLabel = [dateFormatter stringFromDate:lastMessage.sentAt];
    return dateLabel;
}

- (void)configureLayoutConstraintsForLabels
{
    NSDictionary *senderLabelAttributes = @{NSFontAttributeName:self.senderLabel.font};
    CGSize senderLabelSize = [self.senderLabel.text sizeWithAttributes:senderLabelAttributes];
    self.senderLabelHeight = senderLabelSize.height;
    
    NSDictionary *dateLabelAttributes = @{NSFontAttributeName:self.dateLabel.font};
    CGSize dateLabelSize = [self.senderLabel.text sizeWithAttributes:dateLabelAttributes];
    self.dateLabelHeight = dateLabelSize.height;
}

- (void)shouldShowAvatarImage:(BOOL)shouldShowAvatarImage
{
    _shouldShowAvatarImage = shouldShowAvatarImage;
    
    if (shouldShowAvatarImage) {
        
        self.avatarImageView = [[LYRUIAvatarImageView alloc] init];
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.avatarImageView setSenderFirstName:@"Kevin" lastName:@"Coleman"];
        [self.contentView addSubview:self.avatarImageView];
        
        self.cellHorizontalMargin = 12.0f;
    }
    
    [self updateConstraints];
}

- (void)updateConstraints
{
    if (self.shouldShowAvatarImage) {
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
                                                                      constant:self.cellHorizontalMargin]];
        
        // Center vertically
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0
                                                                      constant:0]];
    }
    
    //**********Sender Label Test Constraints**********//
    // Left Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.senderLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:self.cellHorizontalMargin]];
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
                                                                  constant:LSCellVerticalMargin]];
    // Height
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.senderLabel
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:self.senderLabelHeight]];
    
    //**********Message Text Constraints**********//
    //Left Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:self.cellHorizontalMargin]];
    // Right Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:-self.cellHorizontalMargin]];
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
                                                                  constant:0]];
    
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
                                                                  constant:-self.cellHorizontalMargin]];
    // Height
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:self.dateLabelHeight]];
    // Top Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.senderLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat seperatorInset;
    if (self.shouldShowAvatarImage) {
        seperatorInset = self.frame.size.height * LSAvatarImageViewSizeRatio + self.cellHorizontalMargin * 2;
    } else {
        seperatorInset = self.cellHorizontalMargin;
    }
    self.separatorInset = UIEdgeInsetsMake(0, seperatorInset, 0, 0);
    
    // Configure per UI Appearance Proxy
    self.senderLabel.font = self.titleFont;
    self.senderLabel.textColor = self.titleColor;
    self.lastMessageTextView.font = self.subtitleFont;
    self.lastMessageTextView.textColor = self.subtitleColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:FALSE animated:TRUE];
}

@end
