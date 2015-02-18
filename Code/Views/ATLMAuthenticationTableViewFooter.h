//
//  ATLMAuthenticationTableViewFooter.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ATLMAuthenticationState) {
    ATLMAuthenticationStateRegister,
    ATLMAuthenticationStateLogin
};

@class ATLMAuthenticationTableViewFooter;

@protocol ATLMAuthenticationTableViewFooterDelegate <NSObject>

- (void)authenticationTableViewFooter:(ATLMAuthenticationTableViewFooter *)tableViewFooter primaryActionButtonTappedWithAuthenticationState:(ATLMAuthenticationState)authenticationState;

- (void)authenticationTableViewFooter:(ATLMAuthenticationTableViewFooter *)tableViewFooter secondaryActionButtonTappedWithAuthenticationState:(ATLMAuthenticationState)authenticationState;

- (void)environmentButtonTappedForAuthenticationTableViewFooter:(ATLMAuthenticationTableViewFooter *)tableViewFooter;

@end

@interface ATLMAuthenticationTableViewFooter : UIView

@property (nonatomic, weak) id<ATLMAuthenticationTableViewFooterDelegate> delegate;

@property (nonatomic) ATLMAuthenticationState authenticationState;

@end
