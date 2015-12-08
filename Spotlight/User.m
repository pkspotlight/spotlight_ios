//
//  User.m
//  Spotlight
//
//  Created by Peter Kamm on 12/5/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "User.h"

@implementation User

@dynamic profileImage;
@dynamic firstName;
@dynamic lastName;

#pragma mark - Parse Stuff


+ (void)load {
    [self registerSubclass];
}

@end
