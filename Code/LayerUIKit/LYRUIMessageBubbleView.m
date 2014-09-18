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

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *color;

@end

@implementation LYRUIMessageBubbleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.cornerRadius = 12;
        self.clipsToBounds = TRUE;
    
    }
    return self;
}

- (void)updateWithText:(NSString *)text
{
    [self removeSubviewsAndConstraints];
    self.bubbleTextView = [[UITextView alloc] init];
    self.bubbleTextView.backgroundColor = [UIColor clearColor];
    self.bubbleTextView.text = text;
    self.bubbleTextView.scrollEnabled = NO;
    self.bubbleTextView.userInteractionEnabled = NO;
    self.bubbleTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bubbleTextView.textContainerInset = UIEdgeInsetsMake(6, 4, 0, 0);
    [self addSubview:self.bubbleTextView];
    
    [self updateConstraintsForContentView:self.bubbleTextView];
}

- (void) updateWithImage:(UIImage *)image
{
    [self removeSubviewsAndConstraints];
    
    self.bubbleImageView = [[UIImageView alloc] initWithImage:image];
    self.bubbleImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bubbleImageView.layer.cornerRadius = 12;
    self.bubbleImageView.clipsToBounds = TRUE;
    self.bubbleImageView.backgroundColor = [UIColor redColor];
    [self addSubview:self.bubbleImageView];
    
    [self updateConstraintsForContentView:self.bubbleImageView];
}

- (void) updateWithLocation:(CLLocationCoordinate2D)location
{
    //[self removeSubviews];
}

- (void)updateConstraintsForContentView:(UIView *)contentView
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
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
    self.bubbleTextView.textColor = self.color;
    self.bubbleTextView.font = self.font;
}
@end
