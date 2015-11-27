//
//  SpotlightCollectionViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "SpotlightCollectionViewController.h"
#import "SpotlightHeaderCollectionReusableView.h"
#import "SpotlightMediaCollectionViewCell.h"
#import "SpotlightMedia.h"
#import "Team.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD.h>


@interface SpotlightCollectionViewController ()

@property (strong, nonatomic) NSArray* mediaList;
@property (strong, nonatomic) UIImagePickerController* imagePickerController;

@end

@implementation SpotlightCollectionViewController

static NSString * const reuseIdentifier = @"SpotlightMediaCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.spotlight allMedia:^(NSArray *media, NSError *error) {
        self.mediaList = media;
        [self.collectionView reloadData];
    }];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)hidesBottomBarWhenPushed {
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.mediaList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SpotlightMediaCollectionViewCell *cell = (SpotlightMediaCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    SpotlightMedia* media = self.mediaList[indexPath.row];
    [cell formatCellForSpotlightMedia:media];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    
    SpotlightHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                   UICollectionElementKindSectionHeader withReuseIdentifier:@"SpotlightHeaderCollectionReusableView" forIndexPath:indexPath];
    [self updateSectionHeader:headerView forIndexPath:indexPath];
    
    return headerView;
}

- (void)updateSectionHeader:(UICollectionReusableView *)header forIndexPath:(NSIndexPath *)indexPath
{
    Team *team = self.spotlight.team;
    [[(SpotlightHeaderCollectionReusableView*)header teamNameLabel] setText:team.teamName];
    [team.teamLogoMedia fetchIfNeeded];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:team.teamLogoMedia.thumbnailImageFile.url]];
    [[(SpotlightHeaderCollectionReusableView*)header teamImageView]
     setImageWithURLRequest:request
     placeholderImage:nil
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
         [[(SpotlightHeaderCollectionReusableView*)header teamImageView] setImage:image];
     } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
         NSLog(@"fuck thumbnail failure");
     }];
    

    
//    NSString *text = [NSString stringWithFormat:@"header #%i", indexPath.row];
//    header.label.text = text;
}


/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = self.collectionView.bounds.size.width/2;
    return CGSizeMake(width, width);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Create browser (must be done each time photo browser is
    // displayed. Photo browser objects cannot be re-used)
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    // Set options
    browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
    browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    browser.autoPlayOnAppear = YES; // Auto-play first video
    
    // Optionally set the current visible photo before displaying
    [browser setCurrentPhotoIndex:indexPath.row];
    
    // Present
    [self.navigationController pushViewController:browser animated:YES];
}

- (IBAction)addMediaButtonPressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.delegate = self;
        imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
        imagePickerController.videoMaximumDuration = 15;
        [imagePickerController setAllowsEditing:YES];
        
        self.imagePickerController = imagePickerController;
        [self.navigationController presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}


- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.mediaList.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.mediaList.count) {
        return [self mwphotoForSpotlightMedia:[self.mediaList objectAtIndex:index]];
    }
    return nil;
}

- (MWPhoto*)mwphotoForSpotlightMedia:(SpotlightMedia*)media {
    
    if (media.isVideo) {
        MWPhoto *video = [MWPhoto photoWithURL:[NSURL URLWithString:media.thumbnailImageFile.url]];
        video.videoURL = [NSURL URLWithString:media.mediaFile.url];
        return video;
    } else {
        return [MWPhoto photoWithURL:[NSURL URLWithString:media.mediaFile.url]];
    }
}



#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)infoDict {
    
    //   for (NSDictionary* infoDict in infoArray) {
    SpotlightMedia *media;
    NSString *mediaType = [infoDict objectForKey: UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeVideo] ||
        [mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        
        NSURL *videoUrl=(NSURL*)[infoDict objectForKey:UIImagePickerControllerMediaURL];
        NSString *videoPath = [videoUrl path];
        media = [[SpotlightMedia alloc] initWithVideoPath:videoPath];
        
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [infoDict valueForKey:UIImagePickerControllerOriginalImage];
        media = [[SpotlightMedia alloc] initWithImage:image];
    }
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Adding Media..."];
    media[@"parent"] = self.spotlight;
    [media saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"fuck: %@", [error localizedDescription]);
        } else {
            
            [self.spotlight allMedia:^(NSArray *media, NSError *error) {
                
                self.mediaList = media;
                [self.collectionView reloadData];
                [hud hide:YES];
            }];
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
    self.imagePickerController = nil;
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
