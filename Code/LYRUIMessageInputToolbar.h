//
//  LYRUIMessageInputToolbar.h
//  
//
//  Created by Kevin Coleman on 8/31/14.
//
//

#import <UIKit/UIKit.h>
#import "UIMessageComposeTextView.h"

@interface LYRUIMessageInputToolbar : UIToolbar

// auto-resizing message composition field
@property (nonatomic) UIMessageComposeTextView *textView;

// When set, draws to the left of the compose text area. Default to `nil`
@property (nonatomic) UIButton *accessoryButton;

@end