//
//  LSBubbleView.m
//  LayerSample
//
//  Created by Kevin Coleman on 7/7/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSBubbleView.h"
#import "LSUIConstants.h"

static inline CGFloat LSDegreesToRadians(CGFloat angle)
{
    return (angle) / 180.0 * M_PI;
}

@interface LSBubbleView ()

@property (nonatomic) UITextView *textView;
@property (nonatomic) UIView *arrow;
@property (nonatomic) UIImageView *imageView;

@end

@implementation LSBubbleView

- (id)init
{
    self = [super init];
    if (self) {
        
        self.layer.cornerRadius = 4;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
// Commenting out for now because of issues related to overlapping autolayout constraints
//        self.arrow = [[UIView alloc] init];
//        self.arrow.layer.cornerRadius = 2;
//        self.arrow.translatesAutoresizingMaskIntoConstraints = NO;
//        self.arrow.transform = CGAffineTransformMakeRotation(LSDegreesToRadians(45));
//        [self addSubview:self.arrow];
        
        self.textView = [[UITextView alloc] init];
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        self.textView.contentInset = UIEdgeInsetsMake(-4,0,0,0);
        self.textView.userInteractionEnabled = NO;
        self.textView.font = LSMediumFont(14);
        self.textView.textColor = [UIColor whiteColor];
        self.textView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.textView];
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.layer.cornerRadius = 8;
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.imageView];
    
        [self setupConstraintsForView:self.textView];
        [self setupConstraintsForView:self.imageView];
    }
    return self;
}

- (void)setupConstraintsForView:(id)view
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:4]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:-4]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                      attribute:NSLayoutAttributeTop
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self
                                                      attribute:NSLayoutAttributeTop
                                                     multiplier:1.0
                                                       constant:4]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-4]];
    
    
}

- (void)updateViewWithPresenter:(LSMessageCellPresenter *)presenter
{
    LYRMessagePart *part = [presenter.message.parts objectAtIndex:[presenter indexForPart]];
    
    if ([part.MIMEType isEqualToString:LYRMIMETypeTextPlain]) {
        self.imageView.image = nil;
        self.textView.text = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
        
    } else if([part.MIMEType isEqualToString:LYRMIMETypeImagePNG] || [part.MIMEType isEqualToString:@"image/jpeg"]){
        self.textView.text = nil;
        UIImage *image = [[UIImage alloc] initWithData:part.data];
        UIImage *imageToDisplay = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:UIImageOrientationRight];
        [self.imageView setImage:imageToDisplay];
    }
    
    if ([presenter messageWasSentByAuthenticatedUser]) {
        self.backgroundColor = LSBlueColor();
    } else {
        self.backgroundColor = LSGrayColor();
    }
    self.arrow.backgroundColor = [UIColor redColor];
}

- (void)displayArrowForSender
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrow
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrow
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrow
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrow
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];
}

- (void)displayArrowForRecipient
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrow
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:20]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrow
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:20]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrow
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrow
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-10]];
}
@end
