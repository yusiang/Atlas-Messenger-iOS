//
//  LYRUIParticipantPickerTest.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "KIFTestCase.h"
#import <KIF/KIF.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import "KIFSystemTestActor+ViewControllerActions.h"
#import "KIFUITestActor+LSAdditions.h"
#import "LYRCountdownLatch.h"
#import "LSPersistenceManager.h"
#import "LSConversationCellPresenter.h"
#import "LSApplicationController.h"
#import "LSAuthenticationViewController.h"
#import "LSAppDelegate.h"
#import "LYRUIParticipantPickerController.h"

@interface LYRUIParticipantPickerTest : XCTestCase

@property (nonatomic, strong) LSApplicationController *applicationController;
@end

@implementation LYRUIParticipantPickerTest

- (void)setUp
{
    [super setUp];
    self.applicationController =  [(LSAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:5.0];
    [self.applicationController.APIManager deleteAllContactsWithCompletion:^(BOOL completion, NSError *error) {
        [latch decrementCount];
    }];
    [tester waitForTimeInterval:0];
    
    NSError *error;
    [self.applicationController.persistenceManager deleteAllObjects:&error];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//Load a list of contacts from a local mock server, see them present in the UI. (Verify loading spinner?)
- (void)testToVerifyListOfContactsDisplaysAppropriately
{
    NSError *error;
    NSSet *participants = [self.applicationController.persistenceManager persistedUsersWithError:&error];
    expect(error).to.beNil;
    expect(participants).toNot.beNil;
    
    [system presentViewControllerWithClass:[LYRUIParticipantPickerController class] withinNavigationControllerWithNavigationBarClass:[UINavigationController class] toolbarClass:nil configurationBlock:^(id viewController) {
        //(LYRUIParticipantPickerController *)viewController
    }];
}

//Search for a participant with a known name and verify that it appears.
- (void)testToVerifySearchForKnownParticipantDisplaysIntendedResult
{
    
}

//Search for a participant with an unknown name and verify that the list is empty.
- (void)testToVerifYSearchForUnknownParticipantDoesNotDisplayResult
{
    
}

//Configure the picker in single selection mode and verify that it only permits a single selection to be made.
- (void)testToVerifySingleSelectionModeAllowsOnlyOneSelectionAtATime
{
    
}

//Configure the picker in multi-selection mode and verify that it allows multiple selections to be made.
- (void)testToVerifyThatMutltiSelectionModeAllowsMultipleParticipantsToBeSelected
{
    
}

//Verify that tapping a participant once adds a check mark.
- (void)testToVerifyTappingOnParticipantDisplaysACheckmark
{
    
}

//Verify that tapping a participant a second time remove the existing check mark.

- (void)testToVerifyTappingOnAParticipantTwiceRemovesCheckmark
{
    
}

//Test that the colors and fonts can be changed by using the UIAppearance selectors.
- (void)testToVerifyColorAndFontChangeFunctionality
{
    
}

//Verify that the cell can be overridden and a new UI presented.
- (void)testToVerifyCustomCellImplementationFunctionality
{
    
}

//Verify that the row height can be configured.
- (void)testToVerifyCustomRowHeightFunctionality
{
    
}

//Verify that the sectioning can be changed by returning different values for the sectionText property (i.e. first name vs. last name).
-(void)testToVerifySectionTextPropertyFunctionality
{
    
}

//Test that attempting to change the cell class after the view is loaded results in a runtime error.
- (void)testToVerifyChangingCellClassAfterViewLoadRaiseException
{
    
}

//Test that attempting to change the row height after the view is loaded results in a runtime error.
- (void)testToVerifyChangingRowHeightAfterViewLoadRaiseException
{
    
}

@end
