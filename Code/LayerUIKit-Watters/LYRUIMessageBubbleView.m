//
//  LRYUIMessageBubbleVIew.m
//  Pods
//
//  Created by Kevin Coleman on 9/8/14.
//
//

#import "LYRUIMessageBubbleView.h"

@interface LYRUIMessageBubbleView ()


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
        
        self.bubbleContentView = [[UITextView alloc] init];
        self.bubbleContentView.scrollEnabled = NO;
        self.bubbleContentView.userInteractionEnabled = NO;
        self.layer.cornerRadius = 16;
        self.clipsToBounds = TRUE;
        self.bubbleContentView.translatesAutoresizingMaskIntoConstraints = NO;
        self.bubbleContentView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bubbleContentView];
        [self updateConstraints];
        
    }
    return self;
}

- (void)updateWithText:(NSString *)text
{
    self.bubbleContentView.text = text;
    
}

- (void) updateWithImage:(UIImage *)image
{

}

- (void) updateWithLocation:(CLLocationCoordinate2D)location
{
    //
}

- (void)updateConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleContentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-LYRUIBubbleViewPadding * 2]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleContentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleContentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleContentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:8]];
    
    [super updateConstraints];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
}

@end
