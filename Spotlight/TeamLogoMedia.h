//
//  TeamLogoMedia.h
//  Spotlight
//
//  Created by Peter Kamm on 11/26/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <Parse.h>
#import <Parse/PFObject.h>
#import <Parse/PFObject+Subclass.h>
#import "MediaObject.h"

@interface TeamLogoMedia : MediaObject <PFSubclassing>

+ (NSString *)parseClassName;

@end
