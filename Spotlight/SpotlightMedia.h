//
//  SpotlightMedia.h
//  Spotlight
//
//  Created by Peter Kamm on 10/19/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <Parse.h>
#import <Parse/PFObject.h>
#import <Parse/PFObject+Subclass.h>
#import "MediaObject.h"

@class User;

@interface SpotlightMedia : MediaObject <PFSubclassing>

+ (NSString *)parseClassName;

- (void)likeInBackgroundFromUser:(User*)user completion:(void (^)(void))completion;
- (void)unlikeInBackgroundFromUser:(User*)user completion:(void (^)(void))completion;

@end
