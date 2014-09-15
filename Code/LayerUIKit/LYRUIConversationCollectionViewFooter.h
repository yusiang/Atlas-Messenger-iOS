//
//  LYRUIConversationCollectionViewFooter.h
//  Pods
//
//  Created by Kevin Coleman on 9/10/14.
//
//

#import <UIKit/UIKit.h>

@interface LYRUIConversationCollectionViewFooter : UICollectionReusableView

- (void)updateWithAttributedStringForRecipientStatus:(NSString *)recipientStatus;

@end
