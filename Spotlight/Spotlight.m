//
//  Spotlight.m
//  Spotlight
//
//  Created by Peter Kamm on 10/19/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "Spotlight.h"
#import "SpotlightMedia.h"

@implementation Spotlight

@dynamic creatorName;
@dynamic title;
@dynamic team;
@dynamic moderators;
@dynamic spotlightDescription;
@dynamic spotlightTitle;

- (void)allMedia:(void (^)(NSArray *media, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"SpotlightMedia"];
    [query whereKey:@"parent" equalTo:self];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        if (completion) completion(objects, error);
    }];
}

- (void)allImageUrls:(void (^)(NSArray *urls, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"SpotlightMedia"];
    [query whereKey:@"parent" equalTo:self];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *urls = [NSMutableArray arrayWithCapacity:[objects count]];
        if (!error) {
            NSLog(@"Successfully retrieved %lu images.", (unsigned long)objects.count);
            for (SpotlightMedia *media in objects) {
                NSLog(@"%@", media.objectId);
                [urls addObject:media.mediaFile.url];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        if (completion) completion(urls, error);
    }];
}

- (void)allThumbnailUrls:(void (^)(NSArray *urls, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"SpotlightMedia"];
    [query whereKey:@"parent" equalTo:self];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *urls = [NSMutableArray arrayWithCapacity:[objects count]];
        if (!error) {
            NSLog(@"Successfully retrieved %lu images.", (unsigned long)objects.count);
            for (SpotlightMedia *media in objects) {
                NSLog(@"%@", media.objectId);
                [urls addObject:media.thumbnailImageFile.url];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        if (completion) completion(urls, error);
    }];
}


#pragma mark - Parse Stuff

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Spotlight";
}

@end
