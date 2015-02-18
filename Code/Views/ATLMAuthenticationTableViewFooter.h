//
//  ATLMAuthenticationTableViewFooter.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
