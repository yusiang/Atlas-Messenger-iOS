//
//  ATLMInputTableViewCell.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATLMInputTableViewCell : UITableViewCell

@property (nonatomic) UITextField *textField;

- (void)setGuideText:(NSString *)guideText;

- (void)setPlaceHolderText:(NSString *)placeHolderText;

@end
