//
//  User.m
//  Spotlight
//
//  Created by Peter Kamm on 12/5/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "User.h"

@implementation User

@dynamic profilePic;
@dynamic firstName;
@dynamic lastName;
@dynamic friends;

#pragma mark - Parse Stuff


+ (void)load {
    [self registerSubclass];
}

- (NSString*)displayName {
    NSString* displayName = self.username;
    if (self.firstName) {
        displayName = self.firstName;
        if (self.lastName) {
            displayName = [NSString stringWithFormat:@"%@ %@", displayName, self.lastName];
        }
    }
    return displayName;
}
@end
