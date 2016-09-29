//
//  SpotlightMedia.m
//  Spotlight
//
//  Created by Peter Kamm on 10/19/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "SpotlightMedia.h"
#import "User.h"

@implementation SpotlightMedia
@dynamic timeStamp;
@dynamic participantArray;
+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"SpotlightMedia";
}

- (void)likeInBackgroundFromUser:(User*)user completion:(void (^)(void))completion{
    [self.likes addObject:user];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (completion) {
            completion();
        }
    }];
}

- (void)unlikeInBackgroundFromUser:(User*)user completion:(void (^)(void))completion{
    [self.likes removeObject:user];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (completion) {
            completion();
        }
    }];
}

@end
