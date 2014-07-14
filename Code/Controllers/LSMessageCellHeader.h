//
//  LSMessageCellHeader.h
//  LayerSample
//
//  Created by Kevin Coleman on 7/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSUser.h"

@interface LSMessageCellHeader : UICollectionReusableView

- (void)updateWithSenderName:(NSString *)senderName timeStamp:(NSDate *)timeStamp;

@end
