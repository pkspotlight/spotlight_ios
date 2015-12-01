//
//  ProfilePictureMedia.m
//  Spotlight
//
//  Created by Peter Kamm on 12/1/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "ProfilePictureMedia.h"

@implementation ProfilePictureMedia

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"ProfilePictureMedia";
}

@end
