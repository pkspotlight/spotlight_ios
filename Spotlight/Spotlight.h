//
//  Spotlight.h
//  Spotlight
//
//  Created by Peter Kamm on 10/19/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "PFObject.h"
#import <Parse.h>
#import <Parse/PFObject+Subclass.h>


@interface Spotlight : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

//returns array of urls
- (void)allImageUrls:(void (^)(NSArray *urls, NSError *error))completion;
- (void)allThumbnailUrls:(void (^)(NSArray *urls, NSError *error))completion;

@end
