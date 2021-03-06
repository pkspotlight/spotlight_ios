//
//  SpotlightMedia.m
//  Spotlight
//
//  Created by Peter Kamm on 10/19/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "SpotlightMedia.h"
#import "User.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>

@implementation SpotlightMedia
@dynamic timeStamp;
@dynamic participantArray;
@dynamic mediaFile;
@dynamic thumbnailImageFile;
@dynamic isVideo;
@dynamic likes;
@dynamic title;

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

- (instancetype)initWithVideoPath:(NSURL*)urlPath {
    
    if ( (self = [super init]) ) {
        UIImage* thumbImage = [self generateThumbImage:urlPath];
        self.thumbnailImageFile = [PFFile fileWithName:@"thumb.jpg" data:UIImageJPEGRepresentation(thumbImage, .7)];
        
        NSData *videoData = [NSData dataWithContentsOfURL:urlPath];
        //[NSData dataWithContentsOfFile:path];
        
   //        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:false];
     //   NSData *videoData = [[NSFileManager defaultManager] contentsAtPath:path];
        self.isVideo = YES;
        self.mediaFile = [PFFile fileWithName:@"video.mov" data:videoData];
    }
    return self;
}

- (instancetype)initWithVideoData:(NSData*)data {
    if ( (self = [super init]) ) {
        self.isVideo = YES;
        self.mediaFile = [PFFile fileWithName:@"video.mov" data:data];
    }
    return self;
}

- (void)removeAllParticipants{
    PFRelation *participants = [self relationForKey:@"participantArray"];
    PFQuery *query = [participants query];
    NSArray *array = [query findObjects];
    for(PFObject *object in array){
        [participants removeObject:object];
    }
}

- (instancetype)initWithImage:(UIImage*)image {
    if ( (self = [super init]) ) {
        self.isVideo = NO;
        self.thumbnailImageFile = [PFFile fileWithName:@"thumb.jpg" data:UIImageJPEGRepresentation(image, .5)];
        self.mediaFile = [PFFile fileWithName:@"image.png" data:UIImageJPEGRepresentation(image, .8)];
        [self saveInBackground];
    }
    return self;
}

-(UIImage *)generateThumbImage : (NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    
    return thumbnail;
}

- (void)likeCountWithCompletion:(void (^)(NSInteger likes))completion{
    PFQuery* query = [self.likes query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        completion(objects.count);
    }];
}


@end
