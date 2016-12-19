//
//  UIViewController+MediaAddingFunctionality.m
//  Spotlight
//
//  Created by Peter Kamm on 12/17/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import "UIViewController+MediaAddingFunctionality.h"
#import "SpotlightMedia.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <Photos/Photos.h>
#import <MBProgressHUD.h>
#import "PECropViewController.h"



@implementation UIViewController (MediaAddingFunctionality)

@dynamic spotlight;
@dynamic imagePickerController;
@dynamic completion;

- (void)saveImageWithMediaInfo:(NSArray *)info title:(NSString*)title{
    __block SpotlightMedia *media;
    
    for (NSDictionary *infoDict in info){
        NSString *mediaType = [infoDict objectForKey: UIImagePickerControllerMediaType];
        
        if ([mediaType isEqualToString:(NSString *)ALAssetTypeVideo]){
            
            NSURL *videoUrl=(NSURL*)[infoDict objectForKey:UIImagePickerControllerReferenceURL];
            PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[videoUrl] options:nil];
            PHAsset *asset = result.firstObject;
            NSDate *date = asset.creationDate;
            double timestamp = [date timeIntervalSince1970];
            
            
            PHVideoRequestOptions *options=[[PHVideoRequestOptions alloc]init];
            options.version=PHVideoRequestOptionsVersionOriginal;
            [[PHImageManager defaultManager]
             requestAVAssetForVideo:asset
             options:options
             resultHandler:^(AVAsset * avasset, AVAudioMix * audioMix, NSDictionary * info) {
                 AVURLAsset *asset = (AVURLAsset *)avasset;
                 NSURL *url = asset.URL;
                 NSLog(@"url is %@",url);
                 NSString *videoPath = [url path];
                 media = [[SpotlightMedia alloc] initWithVideoPath:videoPath];
                 media.timeStamp = timestamp;
                 if (title) {
                     media.title = title;
                 }
                 dispatch_async(dispatch_get_main_queue(), ^{
                     MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                     [hud setLabelText:@"Adding Media..."];
                     media[@"parent"] = self.spotlight;
                     [media saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                         if (error) {
                             [hud hide:YES];
                             NSLog(@"fuck: %@", [error localizedDescription]);
                             if (self.completion) self.completion();
                         } else {
                             [self.spotlight allMedia:^(NSArray *media, NSError *error) {
                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
                                 [hud hide:YES];
                                 if (self.completion) self.completion();
                             }];
                         }
                     }];
                 });
             }];
        } else if ([mediaType isEqualToString:(NSString *)ALAssetTypePhoto]) {
            UIImage *image = [infoDict valueForKey:UIImagePickerControllerOriginalImage];
            
            NSURL *imageUrl=(NSURL*)[infoDict objectForKey:UIImagePickerControllerReferenceURL];
            PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[imageUrl] options:nil];
            PHAsset *asset = result.firstObject;
            NSDate *date = asset.creationDate;
            double timestamp = [date timeIntervalSince1970];
            
            media = [[SpotlightMedia alloc] initWithImage:image];
            media.timeStamp = timestamp;
            
            if (title) {
                media.title = title;
            }
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [hud setLabelText:@"Adding Media..."];
            [hud setDimBackground:YES];
            hud.userInteractionEnabled = YES;
            media[@"parent"] = self.spotlight;
            [media saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (error) {
                    [hud hide:YES];
                    NSLog(@"fuck: %@", [error localizedDescription]);
                    if (self.completion) self.completion();
                } else {
                    [self.spotlight allMedia:^(NSArray *media, NSError *error) {
                        [hud hide:YES];
                        if (self.completion) self.completion();
                    }];
                }
            }];
            
        }
    }
    self.imagePickerController = nil;
}

- (void)saveImageWithMediaInfoVideo:(NSDictionary<NSString *,id> *)infoDict title:(NSString*)title{
    SpotlightMedia *media;
    NSString *mediaType = [infoDict objectForKey: UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeVideo] ||
        [mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        
        NSURL *videoUrlDate=(NSURL*)[infoDict objectForKey:UIImagePickerControllerReferenceURL];
        PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[videoUrlDate] options:nil];
        PHAsset *asset = result.firstObject;
        NSDate *date = asset.creationDate;
        double timestamp = [date timeIntervalSince1970];
        
        
        NSURL *videoUrl=(NSURL*)[infoDict objectForKey:UIImagePickerControllerMediaURL];
        NSString *videoPath = [videoUrl absoluteString];
        media = [[SpotlightMedia alloc] initWithVideoPath:videoPath];
        media.timeStamp =timestamp;
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [infoDict valueForKey:UIImagePickerControllerOriginalImage];
        media = [[SpotlightMedia alloc] initWithImage:image];
    }
    if (title) {
        media.title = title;
    }
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [hud setLabelText:@"Adding Media..."];
    [hud setDimBackground:YES];
    hud.userInteractionEnabled = YES;
    media[@"parent"] = self.spotlight;
    [media saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"fuck: %@", [error localizedDescription]);
            if (self.completion) self.completion();
        } else {
            NSLog(@"Successfully saved media");
            [self.spotlight allMedia:^(NSArray *media, NSError *error) {
                NSLog(@"Successfully media to spotlight");

                [hud hide:YES];
                if (self.completion) self.completion();
            }];
        }
    }];
    self.imagePickerController = nil;
}


- (IBAction)addMediaButtonPressedCompletion:(void (^)())completion {
    self.completion = completion;
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Select Source"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Choose Photos"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self selectImagesFromElcImagePicker];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Choose Video"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self selectVideoFromNativeImagePicker];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)selectVideoFromNativeImagePicker{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.delegate = self;
        imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,  nil];
        imagePickerController.videoMaximumDuration = 15;
        [imagePickerController setAllowsEditing:YES];

        self.imagePickerController = imagePickerController;
        [self.navigationController presentViewController:self.imagePickerController animated:YES completion:nil];
    }
    
}

-(void)selectImagesFromElcImagePicker{
    
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] init];
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
    elcPicker.imagePickerDelegate = self;
    [self presentViewController:elcPicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)infoDict {
    [self dismissViewControllerAnimated:YES completion:^{
        [self saveImageWithMediaInfoVideo:infoDict title:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (self.completion) self.completion();
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        [self saveImageWithMediaInfo:info title:nil];
    }];
}
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    if (self.completion) self.completion();
}

@end
