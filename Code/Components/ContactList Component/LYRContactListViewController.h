//
//  LYRContactListViewController.h
//  LayerSample
//
//  Created by Zac White on 8/21/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRContactPresenter.h"

@class LYRContactListViewController;

@protocol LYRContactListDataSource <NSObject>

@required

/**
 *  Asks the data source for the number of Sections to display in the LYRContactListViewController.
 *
 *  @param contactListViewController An object representing the contact list view controller requesting this information.
 *
 *  @return The number of sectionsto display.
 */
- (NSUInteger)numberOfSectionsInViewController:(LYRContactListViewController *)contactListViewController;

/**
 *  Asks the data source for the number of contacts to display in the LYRContactListViewController.
 *
 *  @param contactListViewController An object representing the contact list view controller requesting this information.
 *  @param section                   The section
 *
 *  @return The number of contacts for the section
 */
- (NSUInteger)contactListViewController:(LYRContactListViewController *)contactListViewController numberOfContactsInSection:(NSUInteger)section;

/**
 *  Asks the data source for a cell presenter object for a contact at an index.
 *
 *  @param contactListViewController An object representing the contact list view controller requesting this information.
 *  @param index                     The index of the contact.
 *
 *  @return An instance conforming to the LYRContactPresenter protocol.
 */
- (id<LYRContactPresenter>)contactListViewController:(LYRContactListViewController *)contactListViewController presenterForContactAtIndexPath:(NSIndexPath *)indexPath;

@optional

/**
 *  Called when the contact list view controller will begin a search. This should be used as an indication that all calls to the data source methods should return information about the search results.
 *
 *  @param contactListViewController The contact list view controller beginning the search.
 */
- (void)contactListViewControllerWillBeginSearch:(LYRContactListViewController *)contactListViewController;

/**
 *  Called when the contact list view controller did end a search. This should be used as an indication that all calls to the data source methods should return information about the full data set.
 *
 *  @param contactListViewController The contact list view controller that just finished search.
 */
- (void)contactListViewControllerDidEndSearch:(LYRContactListViewController *)contactListViewController;

/**
 *  Informs the data source that a search has been made with the following search string. After the completion block is called, the `contactListViewController:presenterForContactAtIndex:` method will be called for each search result.
 *
 *  @param contactListViewController An object representing the contact list view controller.
 *  @param searchString              The search string that was just used for search.
 *  @param completion                The completion block that should be called when the results are fetched from the search.
 */

- (void)contactListViewController:(LYRContactListViewController *)contactListViewController didSearchWithString:(NSString *)searchString completion:(void (^)())completion;

@end

@protocol LYRContactListDelegate <NSObject>

/**
 *  Called on the delegate when a contact is selected.
 *
 *  @param contactListViewController The contact list view controller object informing the delegate of the contact selection.
 *  @param index                     The index of the selected contact.
 */
- (void)contactListViewController:(LYRContactListViewController *)contactListViewController didSelectContactAtIndexPath:(NSIndexPath *)indexPath;


- (CGFloat)contactListViewController:(LYRContactListViewController *)contactListViewController heightForContactAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface LYRContactListViewController : UITableViewController <LYRContactListDataSource, LYRContactListDelegate>

/// The search bar used for search.
@property (readonly, nonatomic) UISearchBar *searchBar;

/// The data source for displaying the list of contacts.
@property (weak, nonatomic) id<LYRContactListDataSource> dataSource;

/// The delegate for the contact list view controller.
@property (weak, nonatomic) id<LYRContactListDelegate> delegate;

/**
 *  Forces a reload of all contacts.
 */
- (void)reloadContacts;

@end
