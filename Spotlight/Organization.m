//
//  Organization.m
//  Spotlight
//
//  Created by Peter Kamm on 3/21/17.
//  Copyright © 2017 Spotlight. All rights reserved.
//

#import "Organization.h"

@implementation Organization

@dynamic orgName;
@dynamic orgLogo;
@dynamic orgOwners;
@dynamic teams;


#pragma mark - Parse Stuff
+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Organization";
}

@end
