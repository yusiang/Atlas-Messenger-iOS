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

@property (nonatomic) NSLayoutConstraint *contentWidthConstraint;
@property (nonatomic) NSLayoutConstraint *contentHeightConstraint;
@property (nonatomic) NSLayoutConstraint *contentCenterXConstraint;
@property (nonatomic) NSLayoutConstraint *contentCenterYConstraint;

@property (nonatomic) UIFont *font;
@property (nonatomic) UIColor *color;

@end

@implementation LYRUIMessageBubbleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 12;
        self.clipsToBounds = TRUE;
        self.bubbleTextView = [[UITextView alloc] init];
        self.bubbleTextView.backgroundColor = [UIColor clearColor];
        self.bubbleTextView.scrollEnabled = NO;
        self.bubbleTextView.userInteractionEnabled = NO;
        self.bubbleTextView.translatesAutoresizingMaskIntoConstraints = NO;
        self.bubbleTextView.textContainerInset = UIEdgeInsetsMake(8, 4, 0, 0);
        [self addSubview:self.bubbleTextView];
        [self updateConstraintsForContentView:self.bubbleTextView];
        self.bubbleImageView = [[UIImageView alloc] init];
        self.bubbleImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.bubbleImageView.layer.cornerRadius = 12;
        self.bubbleImageView.clipsToBounds = TRUE;
        self.bubbleImageView.backgroundColor = [UIColor redColor];
        [self addSubview:self.bubbleImageView];
        [self updateConstraintsForContentView:self.bubbleImageView];
    }
    return self;
}

- (void)updateWithText:(NSString *)text
{
    self.bubbleImageView.alpha = 0.0;
    self.bubbleTextView.alpha = 1.0;
    self.bubbleTextView.text = text;
}

- (void)updateWithImage:(UIImage *)image
{
    self.bubbleTextView.alpha = 0.0;
    self.bubbleImageView.alpha = 1.0;
    self.bubbleImageView.image = image;
}

- (void)updateWithLocation:(CLLocationCoordinate2D)location
{
    //[self removeSubviews];
}

- (void)updateConstraintsForContentView:(UIView *)contentView
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self updateConstraints];
}

- (void)updateBubbleViewWithFont:(UIFont *)font color:(UIColor *)color
{
    if (self.font != font) {
       self.font = font;
    }
    if (self.color != color) {
        self.color = color;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bubbleTextView.textColor = self.color;
    self.bubbleTextView.font = self.font;
}

@end
