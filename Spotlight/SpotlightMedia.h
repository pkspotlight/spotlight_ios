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

@interface SpotlightMedia : PFObject <PFSubclassing>

- (instancetype)initWithVideoPath:(NSString*)path;
- (instancetype)initWithImage:(UIImage*)image;

+ (NSString *)parseClassName;

@property (strong, nonatomic) PFFile *mediaFile;
@property (strong, nonatomic) PFFile *thumbnailImageFile;
@property (assign, nonatomic) BOOL isVideo;

@end
