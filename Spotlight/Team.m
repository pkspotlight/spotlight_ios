//
//  Team.m
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "Team.h"

@implementation Team

@dynamic teamName;
@dynamic teamLogoMedia;
@dynamic season;
@dynamic year;
@dynamic town;
@dynamic grade;
@dynamic sport;
@dynamic moderators;
@dynamic spectatorsArray;

#pragma mark - Parse Stuff
+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Team";
}


@end
