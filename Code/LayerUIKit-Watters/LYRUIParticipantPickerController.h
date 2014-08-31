//
//  LYRUIParticipantPickerController.h
//  
//
//  Created by Kevin Coleman on 8/29/14.
//
//

#import <UIKit/UIKit.h>
#import "LYRUIParticipantTableViewCell.h"
#import "LYRUIParticipant.h"

@class LYRUIParticipantPickerController;

/**
 @abstract The `LYRUIParticipantPickerControllerDelegate` protocol must be adopted by objects that wish to act
 as the delegate for a `LYRUIParticipantPickerController` object.
 */
@protocol LYRUIParticipantPickerControllerDelegate <NSObject>

/**
 @abstract Tells the receiver that the participant selection view was dismissed without making a selection.
 @param participantSelectionViewController The participant selection view that was dismissed.
 */
- (void)participantSelectionViewControllerDidCancel:(LYRUIParticipantPickerController *)participantSelectionViewController;

/**
 @abstract Tells the receiver that the user has selected a set of participants from a participant selection view.
 @param participantSelectionViewController The participant selection view in which the selection was made.
 @param participants The set of participants that was selected.
 */
- (void)participantSelectionViewController:(LYRUIParticipantPickerController *)participantSelectionViewController didSelectParticipants:(NSSet *)participants;

@end

typedef enum  {
    LYRUIParticipantPickerControllerSortTypeFirst,
    LYRUIParticipantPickerControllerSortTypeLast,
}LYRUIParticipantPickerSortType;

@interface LYRUIParticipantPickerController : UINavigationController

///------------------------------------
/// @name Creating a Participant Picker
///------------------------------------

/**
 @abstract Creates and returns a participant picker initialized with the given set of participants.
 @param participants The set of participants to display in the picker. Each object in the given set must conform to the `LYRUIParticipant` protocol.
 @returns A new participant picker initialized with the given set of participants.
 @raises NSInvalidArgumentException Raised if any object in the given set of participants does not conform to the `LYRUIParticipant` protocol.
 */
+ (instancetype)participantPickerWithParticipants:(NSSet *)participants;

///----------------------------------------
/// @name Accessing the Set of Participants
///----------------------------------------

/**
 @abstract Returns the set of participants with which the receiver was initialized.
 */
@property (nonatomic, readonly) NSSet *participants;

///-----------------------------------------
/// @name Accessing the Picker Delegate
///-----------------------------------------

@property (nonatomic, weak) id<LYRUIParticipantPickerControllerDelegate> participantPickerDelegate;

///---------------------------------
/// @name Configuring Picker Options
///---------------------------------

/**
 @abstract A Boolean value that determines whether multiple participants can be selected at once.
 @discussion The defauly value of this property is `YES`.
 */
@property (nonatomic, assign) BOOL allowsMultipleSelection;

/**
 @abstract The table view cell class for customizing the display of participants.
 @default `[LYRUIParticipantTableViewCell class]`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic) Class<LYRUIParticipantPresenting> cellClass;

@property (nonatomic, assign) LYRUIParticipantPickerSortType participantPickerSortType;

@end




