//
//  LSAuthenticationTableViewFooter.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    LSAuthenticationStateRegister,
    LSAuthenticationStateLogin
}LSAuthenticationState;

@class LSAuthenticationTableViewFooter;

@protocol LSAuthenticationTableViewFooterDelegate <NSObject>

- (void)authenticationTableViewFooter:(LSAuthenticationTableViewFooter *)tableViewFooter primaryActionButtonTappedWithAuthenticationState:(LSAuthenticationState)authenticationState;

- (void)authenticationTableViewFooter:(LSAuthenticationTableViewFooter *)tableViewFooter secondaryActionButtonTappedWithAuthenticationState:(LSAuthenticationState)authenticationState;
@end

@interface LSAuthenticationTableViewFooter : UIView

@property (nonatomic, weak) id<LSAuthenticationTableViewFooterDelegate>delegate;
@end
