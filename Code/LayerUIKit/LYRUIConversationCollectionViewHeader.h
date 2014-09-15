//
//  LYRUIConversationCollectionViewHeader.h
//  Pods
//
//  Created by Kevin Coleman on 9/10/14.
//
//

#import <UIKit/UIKit.h>

@interface LYRUIConversationCollectionViewHeader : UICollectionReusableView

- (void)updateWithAttributedStringForDate:(NSString *)date;

- (void)updateWithAttributedStringForParticipantName:(NSString *)participantName;

@end
