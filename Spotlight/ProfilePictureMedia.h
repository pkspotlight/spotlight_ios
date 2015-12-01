//
//  ProfilePictureMedia.h
//  Spotlight
//
//  Created by Peter Kamm on 12/1/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "MediaObject.h"
#import <Parse.h>
#import <Parse/PFObject.h>
#import <Parse/PFObject+Subclass.h>

@interface ProfilePictureMedia : MediaObject <PFSubclassing>

+ (NSString *)parseClassName;

@end