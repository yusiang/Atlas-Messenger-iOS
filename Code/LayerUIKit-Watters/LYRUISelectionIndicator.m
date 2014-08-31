//
//  LYRUISelectionIndicator.m
//  Pods
//
//  Created by Kevin Coleman on 8/31/14.
//
//

#import "LYRUISelectionIndicator.h"
#import "LYRUIConstants.h"

static inline CGFloat LSDegreesToRadians(CGFloat angle)
{
    return (angle) / 180.0 * M_PI;
}

@interface LYRUISelectionIndicator ()

@property (nonatomic, strong) UIView *cutout;
@property (nonatomic, strong) UIView *checkMark;

@end

@implementation LYRUISelectionIndicator

+ (instancetype)initWithDiameter:(CGFloat)diameter
{
    return [[self alloc] initWithDiameter:diameter];
}

- (id)initWithDiameter:(CGFloat)diameter
{
    self = [super init];
    if (self) {
        
        self.layer.cornerRadius = diameter / 2;
        
        self.backgroundColor = [UIColor redColor];
        self.layer.borderWidth = 1;
        self.layer.borderColor = LSGrayColor().CGColor;
        
        [self initCheckMark];
    }
    return self;
}

#define DegreesToRadians(angle) ((angle) / 180.0 * M_PI)
- (void)initCheckMark
{
    self.checkMark = [[UIView alloc] initWithFrame:CGRectMake(6, 8, 16, 10)];
    self.checkMark.backgroundColor = LSBlueColor();
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:(CGPoint){0, 0}];
    [path addLineToPoint:(CGPoint){4, 0}];
    [path addLineToPoint:(CGPoint){4, 6}];
    [path addLineToPoint:(CGPoint){16, 6}];
    [path addLineToPoint:(CGPoint){16, 12}];
    [path addLineToPoint:(CGPoint){0, 12}];
    
    CAShapeLayer *mask = [CAShapeLayer new];
    mask.frame = self.checkMark.bounds;
    mask.path = path.CGPath;
    
    self.checkMark.layer.mask = mask;
    self.checkMark.accessibilityLabel = @"Selected Checkmark";
    self.checkMark.transform = CGAffineTransformMakeRotation(LSDegreesToRadians(-45));
    
    self.checkMark.alpha = 0.0f;
    [self addSubview:self.checkMark];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.backgroundColor = LSGrayColor();
        self.checkMark.alpha = 1.0;
    } else {
        self.backgroundColor = [UIColor whiteColor];
        self.checkMark.alpha = 0.0;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}
@end
