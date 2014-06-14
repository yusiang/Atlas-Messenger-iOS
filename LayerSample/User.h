//
//  User.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/13/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSSet *contacts;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addContactsObject:(User *)value;
- (void)removeContactsObject:(User *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

@end
