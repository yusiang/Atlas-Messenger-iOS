//
//  LYRUIMessageInputToolbar.h
//  Pods
//
//  Created by Kevin Coleman on 9/18/14.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LYRUIMessageComposeTextView.h"

@class LYRUIMessageInputToolbar;

@protocol LYRUIMessageInputToolbarDelegate <NSObject>

- (void)messageInputToolbar:(LYRUIMessageInputToolbar *)messageInputToolbar didTapRightAccessoryButton:(UIButton *)rightAccessoryButton;

- (void)messageInputToolbar:(LYRUIMessageInputToolbar *)messageInputToolbar didTapLeftAccessoryButton:(UIButton *)leftAccessoryButton;

@end

@interface LYRUIMessageInputToolbar : UIToolbar

- (void)insertImage:(UIImage *)image;

- (void)insertVideoAtPath:(NSString *)videoPath;

- (void)insertAudioAtPath:(NSString *)path;

- (void)insertLocation:(CLLocationCoordinate2D)location;

@property (nonatomic, strong) UIButton *leftAccessoryButton;

@property (nonatomic, strong) UIButton *rightAccessoryButton;

@property (nonatomic, strong) LYRUIMessageComposeTextView *textInputView;

@property (nonatomic, weak) id<LYRUIMessageInputToolbarDelegate>delegate;

@property (nonatomic) NSMutableArray *messageContentParts;

@end
