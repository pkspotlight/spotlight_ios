//
//  Child.m
//  Spotlight
//
//  Created by Peter Kamm on 2/10/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import "Child.h"
#import "Team.h"

@implementation Child

@dynamic profilePic;
@dynamic firstName;
@dynamic lastName;
@dynamic hometown;
@dynamic birthDate;
@dynamic friends;
@dynamic teams;

#pragma mark - Parse Stuff


+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Child";
}


- (NSString*)displayName {
    NSString* displayName = @"Unnamed";
    if (self.firstName) {
        displayName = self.firstName;
        if (self.lastName) {
            displayName = [NSString stringWithFormat:@"%@ %@", displayName, self.lastName];
        }
    }
    return displayName;
}

- (void)followTeam:(Team*)team completion:(void (^)(void))completion{
    [[self teams] addObject:team];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (completion) {
            completion();
        }
    }];
}

@end
