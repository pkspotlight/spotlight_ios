//
//  SpotlightCollectionViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Spotlight.h"
#import "MWPhotoBrowser.h"
#import "ELCImagePickerController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ReorderSpolightImagesTableViewController.h"

@interface SpotlightCollectionViewController : UICollectionViewController <MWPhotoBrowserDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout,ELCImagePickerControllerDelegate,MPMediaPickerControllerDelegate,RefreshTableDelegate>

@property (strong, nonatomic) Spotlight* spotlight;

-(void)photoBrowser:(MWPhotoBrowser *)photoBrowser likePhotoAtIndex:(NSUInteger)index;

@end
