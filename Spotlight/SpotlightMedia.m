//
//  SpotlightMedia.m
//  Spotlight
//
//  Created by Peter Kamm on 10/19/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "SpotlightMedia.h"

@implementation SpotlightMedia

@dynamic mediaFile;


- (instancetype)initWithVideoData:(NSData*)data {
    
    if ( (self = [super init]) ) {
        self.mediaFile = [PFFile fileWithName:@"video.mov" data:data];
        [self.mediaFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded) {
                NSLog(@"sweet it uploaded");
            } else {
                NSLog(@"fuck it didnt");
            }
        }];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage*)image {
    
    if ( (self = [super init]) ) {
        self.mediaFile = [PFFile fileWithName:@"image.png" data:UIImageJPEGRepresentation(image, .6)];
        [self.mediaFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded) {
                NSLog(@"sweet it uploaded");
            } else {
                NSLog(@"fuck it didnt");
            }
        }];
        [self saveInBackground];
    }
    return self;
}


#pragma mark - Parse Stuff


+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"SpotlightMedia";
}


@end
