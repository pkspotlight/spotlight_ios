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

@property(strong, nonatomic) NSString*  creatorName;
@property(strong, nonatomic) NSString*  title;

- (void)allMedia:(void (^)(NSArray *media, NSError *error))completion;
- (void)allImageUrls:(void (^)(NSArray *urls, NSError *error))completion;
- (void)allThumbnailUrls:(void (^)(NSArray *urls, NSError *error))completion;

@end
