//
//  SpotlightMedia.m
//  Spotlight
//
//  Created by Peter Kamm on 10/19/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "SpotlightMedia.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>

@implementation SpotlightMedia

@dynamic mediaFile;
@dynamic thumbnailImageFile;
@dynamic isVideo;

- (instancetype)initWithVideoPath:(NSString*)path {
    
    if ( (self = [super init]) ) {
        UIImage* thumbImage = [self generateThumbImage:path];
        self.thumbnailImageFile = [PFFile fileWithName:@"thumb.jpg" data:UIImageJPEGRepresentation(thumbImage, 1)];
        NSData *videoData = [[NSFileManager defaultManager] contentsAtPath:path];
        self.isVideo = YES;
        self.mediaFile = [PFFile fileWithName:@"video.mov" data:videoData];
        [self saveInBackground];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage*)image {
    
    if ( (self = [super init]) ) {
        self.isVideo = NO;
        self.thumbnailImageFile = [PFFile fileWithName:@"thumb.jpg" data:UIImageJPEGRepresentation(image, .6)];
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

#pragma mark - Parse Stuff


+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"SpotlightMedia";
}


@end
