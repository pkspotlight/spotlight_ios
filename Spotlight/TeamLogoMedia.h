//
//  TeamLogoMedia.h
//  Spotlight
//
//  Created by Peter Kamm on 11/26/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject.h>
#import <Parse/PFObject+Subclass.h>
#import "MediaObject.h"

@interface TeamLogoMedia : PFObject <PFSubclassing>
- (instancetype)initWithVideoPath:(NSString*)path;
- (instancetype)initWithImage:(UIImage*)image;
- (instancetype)initWithVideoData:(NSData*)data;
- (void)likeCountWithCompletion:(void (^)(NSInteger likes))completion;

@property (strong, nonatomic) PFFile *mediaFile;
@property (strong, nonatomic) PFFile *thumbnailImageFile;
@property (strong, nonatomic) NSString* title;
@property (assign, nonatomic) BOOL isVideo;
@property (readonly, nonatomic) PFRelation* likes;
+ (NSString *)parseClassName;

@end
