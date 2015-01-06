//
//  LSAuthenticationTableViewFooter.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LSAuthenticationState) {
    LSAuthenticationStateRegister,
    LSAuthenticationStateLogin
};

@class LSAuthenticationTableViewFooter;

@protocol LSAuthenticationTableViewFooterDelegate <NSObject>

- (void)authenticationTableViewFooter:(LSAuthenticationTableViewFooter *)tableViewFooter primaryActionButtonTappedWithAuthenticationState:(LSAuthenticationState)authenticationState;

- (void)authenticationTableViewFooter:(LSAuthenticationTableViewFooter *)tableViewFooter secondaryActionButtonTappedWithAuthenticationState:(LSAuthenticationState)authenticationState;

- (void)environmentButtonTappedForAuthenticationTableViewFooter:(LSAuthenticationTableViewFooter *)tableViewFooter;

@end

@interface LSAuthenticationTableViewFooter : UIView

@property (nonatomic, weak) id<LSAuthenticationTableViewFooterDelegate>delegate;

@property (nonatomic) LSAuthenticationState authenticationState;

@end
