//
//  Spotlight.m
//  Spotlight
//
//  Created by Peter Kamm on 10/19/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "Spotlight.h"

@implementation Spotlight


@dynamic mediaFiles;

#pragma mark - Parse Stuff
+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Spotlight";
}

@end
