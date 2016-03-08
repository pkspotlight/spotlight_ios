//
//  MontageUtilities.m
//  Spotlight
//
//  Created by Peter Kamm on 12/7/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "MontageCreator.h"
#import "SpotlightMedia.h"

#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AFNetworking.h>

@interface MontageCreator()

@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *writerInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *bufferAdapter;
@property (nonatomic, assign) CMTime frameTime;
@property (nonatomic, strong) NSDictionary *videoSettings;
@property (nonatomic, assign) BOOL isWritingPhotoVideo;

@end

@implementation MontageCreator

+ (MontageCreator *)sharedCreator {
    static dispatch_once_t pred;
    static MontageCreator *sharedCreator = nil;
    dispatch_once(&pred,^{
        sharedCreator = [[MontageCreator alloc] init];
        sharedCreator.isWritingPhotoVideo = NO;
    });
    return sharedCreator;
}

- (void)initWritersWithUrlPath:(NSURL*)fileURL {
    NSError *error;
    
    _assetWriter = [[AVAssetWriter alloc] initWithURL:fileURL
                                             fileType:AVFileTypeQuickTimeMovie
                                                error:&error];
    if (error) {
        NSLog(@"Error: %@", error.debugDescription);
    }
    NSParameterAssert(self.assetWriter);
    
    _writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                      outputSettings:self.videoSettings];
    NSParameterAssert(self.writerInput);
    NSParameterAssert([self.assetWriter canAddInput:self.writerInput]);
    
    [self.assetWriter addInput:self.writerInput];
    
    NSDictionary *bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    _bufferAdapter = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:self.writerInput sourcePixelBufferAttributes:bufferAttributes];
    _frameTime = CMTimeMake(1, 1);
}

- (void)createMontageWithMedia:(NSArray*)mediaArray
                     songTitle:(NSString*)songTitle
                    completion:(void (^)(AVPlayerItem* item))completion {

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                                 [NSString stringWithFormat:@"montage.mov"]];
        
        NSFileManager *manager = [NSFileManager defaultManager];

        self.videoSettings = [self videoSettingsWithCodec:AVVideoCodecH264
                                                withWidth:1280
                                                andHeight:720];
        
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *track = [mixComposition
                                            addMutableTrackWithMediaType:AVMediaTypeVideo
                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        CMTime totalDuration = kCMTimeZero;
        NSError* error;
        for (SpotlightMedia *media in mediaArray) {
            
            NSLog(@"downloading...");
            [media fetchIfNeeded];
            NSLog(@"done");
            if (media.isVideo) {
                NSLog(@"attempt...");

                AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:media.mediaFile.url]
                                                        options:nil];
                if (asset && [[asset tracksWithMediaType:AVMediaTypeVideo] count] > 0 ) {
                [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                               ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                atTime:totalDuration
                                 error:&error];
                totalDuration = CMTimeAdd(totalDuration, asset.duration);
                    NSLog(@"woo...");

                } else {
                    continue;
                }
            } else {
                
                NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @"image.mov"];
                NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
                [self initWritersWithUrlPath:fileURL];
                self.isWritingPhotoVideo = YES;
                
                AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:media.thumbnailImageFile.url]]];
                requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
                [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"Response: %@", responseObject);
                    [self createMovieFromImage:(UIImage*)responseObject];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Image error: %@", error);
                }];
                [requestOperation start];
                
                while (self.isWritingPhotoVideo) {
                    [NSThread sleepForTimeInterval:0.05];
                }
                AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL
                                                        options:nil];
                [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                               ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                atTime:totalDuration
                                 error:&error];
                totalDuration = CMTimeAdd(totalDuration, asset.duration);
            }
            
            if (error) {
                NSLog(@"error: %@", [error localizedDescription]);
            }
        }
        NSURL *audio_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:songTitle ofType:@"mp3"]];
        AVURLAsset  *audioAsset = [[AVURLAsset alloc]initWithURL:audio_url options:nil];
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, totalDuration)
                            ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        [manager removeItemAtPath:myPathDocs error:nil];
        NSLog(@"1");

        
        NSMutableArray* instructions = [NSMutableArray array];
        
        AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        videoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
        videoCompositionInstruction.layerInstructions = @[[AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:track]];
        [instructions addObject:videoCompositionInstruction];
        
        AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
        mutableVideoComposition.instructions = instructions;
        mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
        mutableVideoComposition.renderSize = CGSizeMake(1280, 720);
        
        AVPlayerItem *pi = [AVPlayerItem playerItemWithAsset:mixComposition];
        pi.videoComposition = mutableVideoComposition;

        
                dispatch_async(dispatch_get_main_queue(), ^{

        completion(pi);
                });

        
        //all needed
//        AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
//                                          initWithAsset:mixComposition
//                                          presetName:AVMediaTypeVideo];
//        exporter.outputURL = url;
//        exporter.outputFileType = AVFileTypeMPEG4;
//        exporter.shouldOptimizeForNetworkUse = YES;
//        NSLog(@"2");
//
//        [exporter exportAsynchronouslyWithCompletionHandler:^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"3");
//                [self exportDidFinish:exporter];
//                completion();
//                NSLog(@"1");
//
//            });
//        }];
    });
}


- (void)createMovieFromImage:(UIImage *)image
{
    [self.assetWriter startWriting];
    [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
    
    dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
    
    __block NSInteger i = 0;
    
    NSInteger frameNumber = 3;
    // This can prob be significantly more efficient
    [self.writerInput requestMediaDataWhenReadyOnQueue:mediaInputQueue
                                            usingBlock:^{
                                                while (YES){
                                                    if (i >= frameNumber) {
                                                        break;
                                                    }
                                                    if ([self.writerInput isReadyForMoreMediaData]) {
                                                        
                                                        CVPixelBufferRef sampleBuffer = [self newPixelBufferFromCGImage:[image CGImage]];
                                                        
                                                        if (sampleBuffer) {
                                                            if (i == 0) {
                                                                [self.bufferAdapter appendPixelBuffer:sampleBuffer withPresentationTime:kCMTimeZero];
                                                            }else{
                                                                CMTime lastTime = CMTimeMake(i-1, self.frameTime.timescale);
                                                                CMTime presentTime = CMTimeAdd(lastTime, self.frameTime);
                                                                [self.bufferAdapter appendPixelBuffer:sampleBuffer withPresentationTime:presentTime];
                                                            }
                                                            CFRelease(sampleBuffer);
                                                            i++;
                                                        }
                                                    }
                                                }
                                                
                                                [self.writerInput markAsFinished];
                                                [self.assetWriter finishWritingWithCompletionHandler:^{
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        self.isWritingPhotoVideo = NO;
                                                    });
                                                }];
                                                
                                                CVPixelBufferPoolRelease(self.bufferAdapter.pixelBufferPool);
                                            }];
}

- (CVPixelBufferRef)newPixelBufferFromCGImage:(CGImageRef)image
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat frameWidth = [[self.videoSettings objectForKey:AVVideoWidthKey] floatValue];
    CGFloat frameHeight = [[self.videoSettings objectForKey:AVVideoHeightKey] floatValue];
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 4 * frameWidth,
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGSize imageSize = CGSizeMake(CGImageGetWidth(image),
                                  CGImageGetHeight(image));
    CGRect targetBounds = CGRectMake(0, 0, frameWidth, frameHeight);
    CGRect imageRect = AVMakeRectWithAspectRatioInsideRect( imageSize,
                                                           targetBounds);
    
    
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, imageRect, image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

-(void)exportDidFinish:(AVAssetExportSession*)session {
    
    switch (session.status) {
        case AVAssetExportSessionStatusFailed:
            NSLog(@"Export Status %@", session.error);
            NSLog(@"failed");
            break;
            
        case AVAssetExportSessionStatusCancelled:
            NSLog(@"cancelled");
            break;
            
        case AVAssetExportSessionStatusCompleted:
            NSLog(@"complete");
            break;
            
        case AVAssetExportSessionStatusExporting:
            NSLog(@"exporting");
            break;
            
        case AVAssetExportSessionStatusUnknown:
            NSLog(@"unknown");
            break;
            
        case AVAssetExportSessionStatusWaiting:
            NSLog(@"waiting");
            break;
            
        default:
            break;
    }
    //
    //
    //    if (session.status == AVAssetExportSessionStatusCompleted) {
    //        NSURL *outputURL = session.outputURL;
    //        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    //        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
    //            [library writeVideoAtPathToSavedPhotosAlbum:outputURL
    //                                        completionBlock:^(NSURL *assetURL, NSError *error){
    //                dispatch_async(dispatch_get_main_queue(), ^{
    //                    if (error) {
    //                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
    //                                                                        message:@"Video Saving Failed"
    //                                                                       delegate:nil
    //                                                              cancelButtonTitle:@"OK"
    //                                                              otherButtonTitles:nil];
    //                        [alert show];
    //                    } else {
    //                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved"
    //                                                                        message:@"Saved To Photo Album"
    //                                                                       delegate:self
    //                                                              cancelButtonTitle:@"OK"
    //                                                              otherButtonTitles:nil];
    //                        [alert show];
    //                    }
    //                });
    //            }];
    //        }
    //    }
}

- (NSDictionary *)videoSettingsWithCodec:(NSString *)codec withWidth:(CGFloat)width andHeight:(CGFloat)height
{
    if ((int)width % 16 != 0 ) {
        NSLog(@"Warning: video settings width must be divisible by 16.");
    }
    
    NSDictionary *videoSettings = @{AVVideoCodecKey : AVVideoCodecH264,
                                    AVVideoWidthKey : [NSNumber numberWithInt:(int)width],
                                    AVVideoHeightKey : [NSNumber numberWithInt:(int)height]};
    
    return videoSettings;
}

@end
