//
//  MediaObject.m
//  Spotlight
//
//  Created by Peter Kamm on 11/26/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "MediaObject.h"
#import "SpotlightMedia.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>

@implementation MediaObject

@dynamic mediaFile;
@dynamic thumbnailImageFile;
@dynamic isVideo;
@dynamic likes;
@dynamic title;


- (instancetype)initWithVideoPath:(NSString*)path {
    
    if ( (self = [super init]) ) {
        UIImage* thumbImage = [self generateThumbImage:path];
        self.thumbnailImageFile = [PFFile fileWithName:@"thumb.jpg" data:UIImageJPEGRepresentation(thumbImage, .7)];
     
       // NSData *videoData = [NSData dataWithContentsOfFile:path];
          BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:false];
        NSData *videoData = [[NSFileManager defaultManager] contentsAtPath:path];
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


- (instancetype)initWithImage:(UIImage*)image {
    
    if ( (self = [super init]) ) {
        self.isVideo = NO;
        self.thumbnailImageFile = [PFFile fileWithName:@"thumb.jpg" data:UIImageJPEGRepresentation(image, .5)];
        self.mediaFile = [PFFile fileWithName:@"image.png" data:UIImageJPEGRepresentation(image, .8)];
        [self saveInBackground];
    }
    return self;
}

-(UIImage *)generateThumbImage : (NSString *)filepath
{
    NSURL *url = [NSURL fileURLWithPath:filepath];
    
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
