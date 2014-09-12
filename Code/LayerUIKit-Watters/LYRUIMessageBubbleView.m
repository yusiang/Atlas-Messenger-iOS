//
//  LRYUIMessageBubbleVIew.m
//  Pods
//
//  Created by Kevin Coleman on 9/8/14.
//
//

#import "LYRUIMessageBubbleView.h"
#import "LYRUIIncomingMessageCollectionViewCell.h"
#import "LYRUIOutgoingMessageCollectionViewCell.h"

@interface LYRUIMessageBubbleView ()

@property (nonatomic, strong) NSLayoutConstraint *contentWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentCenterXConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentCenterYConstraint;

@property (nonatomic) CGFloat bubbleViewVerticalPadding;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *color;

@end

@implementation LYRUIMessageBubbleView

NSString * const LYRMIMETypeTextPlain = @"text/plain";
NSString * const LYRMIMETypeTextHTML = @"text/HTML";
NSString * const LYRMIMETypeImagePNG = @"image/png";
NSString * const LYRMIMETypeImageJPEG = @"image/jpeg";
NSString * const LYRMIMETypeLocation = @"location/coordinate";

static CGFloat const LYRUIBubbleViewPadding = 8;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.cornerRadius = 16;
        self.clipsToBounds = TRUE;
    
    }
    return self;
}

- (void)updateWithText:(NSString *)text
{
    [self removeSubviewsAndConstraints];

    self.bubbleViewVerticalPadding = 0.0f;
    
    self.bubbleContentView = [[UITextView alloc] init];
    self.bubbleContentView.textColor = [UIColor blackColor];
    self.bubbleContentView.text = text;
    self.bubbleContentView.scrollEnabled = NO;
    self.bubbleContentView.userInteractionEnabled = NO;
    self.bubbleContentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bubbleContentView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.bubbleContentView];
    
    [self updateConstraintsForContentView:self.bubbleContentView];
}

- (void) updateWithImage:(UIImage *)image
{
    [self removeSubviewsAndConstraints];
    
    self.bubbleViewVerticalPadding = 8.0f;
    self.bubbleImageView = [[UIImageView alloc] initWithImage:image];
    self.bubbleImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bubbleImageView.layer.cornerRadius = 8;
    self.bubbleImageView.clipsToBounds = TRUE;
    [self addSubview:self.bubbleImageView];
    
     [self updateConstraintsForContentView:self.bubbleImageView];
}

- (void) updateWithLocation:(CLLocationCoordinate2D)location
{
    //[self removeSubviews];
}

- (void)updateConstraintsForContentView:(UIView *)contentView
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-LYRUIBubbleViewPadding * 2]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-self.bubbleViewVerticalPadding * 2]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.bubbleViewVerticalPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.bubbleViewVerticalPadding]];
    
    [super updateConstraints];
}

- (void)removeSubviewsAndConstraints
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    for (NSLayoutConstraint *constraint in self.constraints) {
        [self removeConstraint:constraint];
    }
}

- (void)updateBubbleViewWithFont:(UIFont *)font color:(UIColor *)color
{
    self.font = font;
    self.color = color;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bubbleContentView.textColor = self.color;
    self.bubbleContentView.font = self.font;
}
@end
