//
//  SpotlightMedia.h
//  Spotlight
//
//  Created by Peter Kamm on 10/19/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject.h>
#import <Parse/PFObject+Subclass.h>
#import "MediaObject.h"

@class User;

@interface SpotlightMedia : PFObject <PFSubclassing>
@property (assign, nonatomic) double timeStamp;
@property (assign, nonatomic) NSArray *participantArray;
+ (NSString *)parseClassName;
-(UIImage *)generateThumbImage : (NSURL *)url;

- (void)likeInBackgroundFromUser:(User*)user completion:(void (^)(void))completion;
- (void)unlikeInBackgroundFromUser:(User*)user completion:(void (^)(void))completion;

- (instancetype)initWithVideoPath:(NSURL*)urlPath;
- (instancetype)initWithImage:(UIImage*)image;
- (instancetype)initWithVideoData:(NSData*)data;
- (void)likeCountWithCompletion:(void (^)(NSInteger likes))completion;
- (void)removeAllParticipants;


@property (strong, nonatomic) PFFile *mediaFile;
@property (strong, nonatomic) PFFile *thumbnailImageFile;
@property (strong, nonatomic) NSString* title;
@property (assign, nonatomic) BOOL isVideo;
@property (readonly, nonatomic) PFRelation* likes;

@end
