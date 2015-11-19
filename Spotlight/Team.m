//
//  Team.m
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "Team.h"

@implementation Team





#pragma mark - Parse Stuff
+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Team";
}


@end
