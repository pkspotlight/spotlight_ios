//
//  SpotlightMedia.m
//  Spotlight
//
//  Created by Peter Kamm on 10/19/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "SpotlightMedia.h"

@implementation SpotlightMedia

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"SpotlightMedia";
}


@end
