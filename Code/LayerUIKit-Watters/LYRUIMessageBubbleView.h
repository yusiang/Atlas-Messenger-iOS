//
//  LRYUIMessageBubbleView.h
//  Pods
//
//  Created by Kevin Coleman on 9/8/14.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

extern NSString * const LYRMIMETypeTextPlain; /// text/plain
extern NSString * const LYRMIMETypeTextHTML;  /// text/html
extern NSString * const LYRMIMETypeImagePNG;  /// image/png
extern NSString * const LYRMIMETypeImageJPEG; /// image/jpeg
extern NSString * const LYRMIMETypeLocation;  /// location/coordinate

@interface LYRUIMessageBubbleView : UIView <UIAppearanceContainer>

- (void)updateWithText:(NSString *)text;

- (void) updateWithImage:(UIImage *)image;

- (void) updateWithLocation:(CLLocationCoordinate2D)location;

- (void)updateBubbleViewWithFont:(UIFont *)font color:(UIColor *)color;

@property (nonatomic, strong) UITextView *bubbleContentView;

@property (nonatomic, strong) UIImageView *bubbleImageView;



@end
