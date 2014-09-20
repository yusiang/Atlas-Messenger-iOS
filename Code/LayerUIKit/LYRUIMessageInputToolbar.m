//
//  LYRUIMessageInputToolbar.m
//  Pods
//
//  Created by Kevin Coleman on 9/18/14.
//
//

#import "LYRUIMessageInputToolbar.h"
#import "LYRUIConstants.h"
#import "LYRUIMediaAttachment.h"
#import "LYRUIUtilities.h"

@interface LYRUIMessageInputToolbar () <UITextViewDelegate>

@property (nonatomic) BOOL keyboardIsOnScreen;
@property (nonatomic) CGFloat textViewContentSizeHeight;
@property (nonatomic) CGSize defaultSize;
@property (nonatomic) CGFloat defaultContentHeight;

@property (nonatomic, strong) NSLayoutConstraint *textViewHeightConstraint;

@end

@implementation LYRUIMessageInputToolbar

// Compose View Margin Constants
static CGFloat const LSComposeviewHorizontalMargin = 6;
static CGFloat const LSComposeviewVerticalMargin = 6;

// Compose View Button Constants
static CGFloat const LSLeftAccessoryButtonWidth = 40;
static CGFloat const LSRightAccessoryButtonWidth = 50;
static CGFloat const LSButtonHeight = 28;

- (id)init
{
    self = [super init];
    if (self) {
    
        // Setup
        self.backgroundColor =  LSLighGrayColor();
        self.messageContentParts = [[NSMutableArray alloc] init];
        
        // Initialize the Camera Button
        self.leftAccessoryButton = [[UIButton alloc] init];
        self.leftAccessoryButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.leftAccessoryButton.accessibilityLabel = @"Camera Button";
        self.leftAccessoryButton.layer.cornerRadius = 2;
        [self.leftAccessoryButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [self.leftAccessoryButton addTarget:self action:@selector(leftAccessoryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.leftAccessoryButton];
        
        // Initialize the Text Input View
        self.textInputView = [[LYRUIMessageComposeTextView alloc] init];
        self.textInputView.delegate = self;
        self.textInputView.text = @"";
        self.textInputView.translatesAutoresizingMaskIntoConstraints = NO;
        self.textInputView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.textInputView.layer.borderWidth = 1;
        self.textInputView.layer.cornerRadius = 4.0f;
        self.textInputView.font = LSLightFont(16);
        self.textInputView.textContainerInset = UIEdgeInsetsMake(4, 0, 0, 0);
        self.textInputView.accessibilityLabel = @"Text Input View";
        [self addSubview:self.textInputView];
        
        // Initialize the Send Button
        self.rightAccessoryButton = [[UIButton alloc] init];
        self.rightAccessoryButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.rightAccessoryButton.accessibilityLabel = @"Send Button";
        self.rightAccessoryButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.rightAccessoryButton setTitle:@"SEND" forState:UIControlStateNormal];
        [self.rightAccessoryButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.rightAccessoryButton setTitleColor:LSBlueColor() forState:UIControlStateHighlighted];
        [self.rightAccessoryButton addTarget:self action:@selector(rightAccessoryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rightAccessoryButton];
        
        [self setupLayoutConstraints];
        
        self.keyboardIsOnScreen = NO;
    }
    
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(320, self.textInputView.intrinsicContentSize.height + 16);
}

#pragma mark Public Content Insertion Methods

- (void)insertImage:(UIImage *)image
{
    [self.messageContentParts addObject:image];
    [self.rightAccessoryButton setHighlighted:TRUE];
    [self.textInputView insertImage:image];
}

- (void)insertVideoAtPath:(NSString *)videoPath
{
    
}

- (void)insertAudioAtPath:(NSString *)path
{
    
}

- (void)insertLocation:(CLLocationCoordinate2D)location
{
    MKMapView *mapView = [[MKMapView alloc] init];
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = mapView.region;
    options.scale = [UIScreen mainScreen].scale;
    options.size = CGSizeMake(100, 200);
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        UIImage *image = snapshot.image;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textInputView.attributedText];
        LYRUIMediaAttachment *textAttachment = [[LYRUIMediaAttachment alloc] init];
        textAttachment.image = image;
        
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [attributedString replaceCharactersInRange:NSMakeRange(0, attributedString.length) withAttributedString:attrStringWithImage];
        self.textInputView.attributedText = attrStringWithImage;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        CGRect rect = LYRUIImageRectConstrainedToSize(imageView.frame.size, CGSizeMake(self.frame.size.width, 120));
    }];
}


#pragma mark Compose View Delegate Methods

- (void)leftAccessoryButtonTapped
{
    [self.delegate messageInputToolbar:self didTapLeftAccessoryButton:self.leftAccessoryButton];
}

- (void)rightAccessoryButtonTapped
{
    if (self.textInputView.text.length > 0 || self.messageContentParts) {
        [self.delegate messageInputToolbar:self didTapRightAccessoryButton:self.rightAccessoryButton];
        [self.rightAccessoryButton setHighlighted:FALSE];
        [self.textInputView setText:@""];
        [self.messageContentParts removeAllObjects];
        self.textInputView.font = LSLightFont(16);
    }
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.intrinsicContentSize.height)];
}


#pragma mark TextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self.rightAccessoryButton setHighlighted:FALSE];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.textInputView.intrinsicContentSize.height + 16)];
    if (textView.text.length > 0) {
        [self.rightAccessoryButton setHighlighted:TRUE];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.attributedText) {
        //Press return key
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    return YES;
}

- (void)setupLayoutConstraints
{
    //**********Camera Button Constraints**********//
    // Width
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAccessoryButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:LSLeftAccessoryButtonWidth]];
    
    // Left Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAccessoryButton
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:LSComposeviewVerticalMargin]];
    // Height
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAccessoryButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:LSButtonHeight]];
    // Bottom Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAccessoryButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-LSComposeviewHorizontalMargin]];
    
    //**********Send Button Constraints**********//
    // Width
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightAccessoryButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:LSRightAccessoryButtonWidth]];
    
    // Right Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightAccessoryButton
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-LSComposeviewVerticalMargin]];
    // Height
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightAccessoryButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:LSButtonHeight]];
    // Bottom Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightAccessoryButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-LSComposeviewHorizontalMargin]];
    
    //**********Text Input View Constraints**********//
    // Left Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.leftAccessoryButton
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:LSComposeviewVerticalMargin]];
    
    // Right Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.rightAccessoryButton
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:-LSComposeviewVerticalMargin]];
    // Top Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:LSComposeviewHorizontalMargin]];
    // Top Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-LSComposeviewVerticalMargin]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end
