//
//  LYRContactListViewController.h
//  LayerSample
//
//  Created by Zac White on 8/21/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRContactCellPresenter.h"

@class LYRContactListViewController;

/**
 *  The contact list data source requests data for the contact list
 */
@protocol LYRContactListDataSource <NSObject>

@required

/**
 *  Asks the data source for the number of Sections to display in the LYRContactListViewController. Sections coorespond to letters in the alphabet
 *
 *  @param contactListViewController An object representing the contact list view controller requesting the information
 *
 *  @return The number of sections to display.
 */
- (NSUInteger)numberOfSectionsInViewController:(LYRContactListViewController *)contactListViewController;

/**
 *  Asks the data source for the number of contacts to display in each section of the LYRContactListViewController.
 *
 *  @param contactListViewController An object representing the contact list view controller requesting the information.
 *  @param section                   The section for which the view controller is requesting the number of contacts
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
- (id<LYRContactCellPresenter>)contactListViewController:(LYRContactListViewController *)contactListViewController presenterForContactAtIndexPath:(NSIndexPath *)indexPath;

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

/**
 *  Called on the delegate when a table view section is about to appear. This method should return a single letter that represents a group of contacts
 *
 *  @param contactListViewController The contact list view controller object requesting the string
 *  @param section                   The section for which a string is being requested
 *
 *  @return The string to be displayed in the section header
 */
- (NSString *)contactListViewController:(LYRContactListViewController *)contactListViewController letterForContactsInSection:(NSUInteger)section;

/**
 *  Called on the delegate when a cell is about to be displayed. Provides controll over the height of contact cells
 *
 *  @param contactListViewController The contact list view controller object requesting the cell height
 *  @param indexPath                 The indexPath for the contact
 *
 *  @return The value for cell height
 */
- (CGFloat)contactListViewController:(LYRContactListViewController *)contactListViewController heightForContactAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Asks the delegate for a selection indicator for a given contact
 *
 *  @param contactListViewController The contact list view controller object requesting the selection indicator
 *  @param indexPath                 The index path for the contact
 *
 *  @return a control object for the selection indicator. This should be a button which has views set for highlighted and normal state
 */
- (UIControl *)contactListViewController:(LYRContactListViewController *)contactListViewController selectionIndicatorForContactAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface LYRContactListViewController : UITableViewController

@property (nonatomic, strong) UITableViewCell *contactTableViewCell;

/// YES if the search is currently active and the search results are expected to be returned in the data source methods.
@property (nonatomic, readonly) BOOL isSearching;

/// The search bar used for search.
@property (nonatomic, readonly) UISearchBar *searchBar;

/// The data source for displaying the list of contacts.
@property (nonatomic, weak) id<LYRContactListDataSource> dataSource;

/// The delegate for the contact list view controller.
@property (nonatomic, weak) id<LYRContactListDelegate> delegate;

/**
 *  Forces a reload of all contacts.
 */
- (void)reloadContacts;

@end

