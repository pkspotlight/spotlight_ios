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


@class Team;

@interface Spotlight : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property(strong, nonatomic) NSString*  creatorName;
@property(strong, nonatomic) NSString*  title;
@property(strong, nonatomic) NSString*  spotlightTitle;
@property(strong, nonatomic) NSString*  spotlightDescription;
@property(strong, nonatomic) Team* team;
@property (readonly, nonatomic) PFRelation* moderators;

- (void)allMedia:(void (^)(NSArray *media, NSError *error))completion;
- (void)allImageUrls:(void (^)(NSArray *urls, NSError *error))completion;
- (void)allThumbnailUrls:(void (^)(NSArray *urls, NSError *error))completion;

@end
