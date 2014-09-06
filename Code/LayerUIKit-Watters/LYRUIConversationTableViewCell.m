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
@property (nonatomic) NSLayoutConstraint *avatarImageHeightConstraint;
@property (nonatomic) NSLayoutConstraint *avatarImageWidthConstraint;

@property (nonatomic) CGFloat senderLabelHeight;
@property (nonatomic) CGFloat senderLabelRightMargin;
@property (nonatomic) CGFloat dateLabelHeight;
@property (nonatomic) CGFloat dateLabelWidth;
@property (nonatomic) CGFloat cellHorizontalMargin;
@property (nonatomic) CGFloat avatarImageSizeRatio;

@end

@implementation LYRUIConversationTableViewCell

// Cell Constants
static CGFloat const LSCellVerticalMargin = 10.0f;

// Date Label Constants
//static CGFloat const LSCellDateLabelLeftMargin = 0.0f;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        if (!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
        }
        
        // Initialize Avatar Image
        self.avatarImageView = [[LYRUIAvatarImageView alloc] init];
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.avatarImageView];
        
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
        self.dateLabel.textAlignment= NSTextAlignmentLeft;
        self.dateLabel.font = LSMediumFont(12);
        self.dateLabel.textColor = [UIColor darkGrayColor];
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.dateLabel];
        
        self.cellHorizontalMargin = 10.0f;
        self.avatarImageSizeRatio = 0.0f;
    }
    return self;
}

- (void)presentConversation:(LYRConversation *)conversation withLabel:(NSString *)conversationLabel
{
    self.accessibilityLabel = conversationLabel;
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
    [self updateLayoutConstraints];
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
    CGSize dateLabelSize = [self.dateLabel.text sizeWithAttributes:dateLabelAttributes];
    self.dateLabelHeight = dateLabelSize.height;
    self.dateLabelWidth = dateLabelSize.width + 4;
    
    self.senderLabelRightMargin = self.dateLabelWidth + 4 + self.cellHorizontalMargin;
}

- (void)shouldShowAvatarImage:(BOOL)shouldShowAvatarImage
{
    _shouldShowAvatarImage = shouldShowAvatarImage;
    
    if (shouldShowAvatarImage) {
        
        self.avatarImageSizeRatio = 0.60f;
        [self.contentView removeConstraint:self.avatarImageWidthConstraint];
        [self.contentView removeConstraint:self.avatarImageHeightConstraint];
        
        self.avatarImageWidthConstraint = [NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.contentView
                                                                      attribute:NSLayoutAttributeHeight
                                                                     multiplier:self.avatarImageSizeRatio
                                                                       constant:0];
        [self.contentView addConstraint:self.avatarImageWidthConstraint];
       
        // Height
       self.avatarImageHeightConstraint = [NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.contentView
                                                                       attribute:NSLayoutAttributeHeight
                                                                      multiplier:self.avatarImageSizeRatio
                                                                        constant:0];
        [self.contentView addConstraint:self.avatarImageHeightConstraint];
        
    }
}

- (void)updateLayoutConstraints
{
    //**********Avatar Constraints**********//
    // Width
    self.avatarImageWidthConstraint = [NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:self.avatarImageSizeRatio
                                                                    constant:0];
    [self.contentView addConstraint:self.avatarImageWidthConstraint];
    
    // Height
    self.avatarImageHeightConstraint = [NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.contentView
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:self.avatarImageSizeRatio
                                                                     constant:0];
    [self.contentView addConstraint:self.avatarImageHeightConstraint];
    
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
                                                                    toItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:-2]];
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
    //**********Date Label Constraints**********//

    // Right Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:-self.cellHorizontalMargin]];

    // Top Margi
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.senderLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];

    //**********Message Text Constraints**********//
    //Left Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.senderLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:0]];
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
                                                                  constant:-LSCellVerticalMargin]];
    
    [self.senderLabel setContentCompressionResistancePriority: UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat seperatorInset;
    if (self.shouldShowAvatarImage) {
        seperatorInset = self.frame.size.height * self.avatarImageSizeRatio + self.cellHorizontalMargin * 2;
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
