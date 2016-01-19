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
#import "MontageCreator.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import <MBProgressHUD.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface SpotlightCollectionViewController ()

@property (strong, nonatomic) NSArray* mediaList;
@property (strong, nonatomic) UIImagePickerController* imagePickerController;
@property (assign, nonatomic) BOOL isShowingMontage;
@property (weak, nonatomic) IBOutlet UIButton *viewSpotlightButton;
@property (strong, nonatomic) MWPhotoBrowser *browser;

@end

@implementation SpotlightCollectionViewController

static NSString * const reuseIdentifier = @"SpotlightMediaCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    [refreshControl beginRefreshing];
    [self refresh:refreshControl];
    
    // Do any additional setup after loading the view.
}

- (void)refresh:(UIRefreshControl*)refresh {
    [self.spotlight allMedia:^(NSArray *media, NSError *error) {
        self.mediaList = media;
        [self.collectionView reloadData];
        [refresh endRefreshing];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isShowingMontage = NO;
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
    [headerView formatHeaderForTeam:self.spotlight.team spotlight:self.spotlight ];
    [headerView setDelegate:self];
    return headerView;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = self.collectionView.bounds.size.width/2;
    return CGSizeMake(width, width);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Create browser (must be done each time photo browser is
    // displayed. Photo browser objects cannot be re-used)
    self.browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    // Set options
    self.browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    self.browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    self.browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
    self.browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    self.browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    self.browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    self.browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    self.browser.autoPlayOnAppear = YES; // Auto-play first video
    
    // Optionally set the current visible photo before displaying
    [self.browser setCurrentPhotoIndex:indexPath.row];
    
    // Present
    [self.navigationController pushViewController:self.browser animated:YES];
}

-(void)photoBrowser:(MWPhotoBrowser *)photoBrowser deletePhotoAtIndex:(NSUInteger)index {
    
    [self.navigationController popViewControllerAnimated:YES];
    SpotlightMedia *media = self.mediaList[index];
    [media deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self refresh:nil];
    }];
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
    return self.isShowingMontage ? 1 : self.mediaList.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (self.isShowingMontage) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                                 [NSString stringWithFormat:@"montage.mov"]];
        MWPhoto *video = [MWPhoto videoWithURL:[NSURL URLWithString:myPathDocs]];
        video.videoURL = [NSURL URLWithString:myPathDocs];
        return video;
    } else {
        
        if (index < self.mediaList.count) {
            return [self mwphotoForSpotlightMedia:[self.mediaList objectAtIndex:index]];
        }
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

#pragma mark - Montage Functions

- (IBAction)viewMontageButtonPressed:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Creating Reel..."];
    [[MontageCreator sharedCreator] createMontageWithMedia:[self.mediaList copy] completion:^{
//        self.isShowingMontage = YES;
//        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
//        
//        // Set options
//        browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
//        browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
//        browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
//        browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
//        browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
//        browser.enableGrid = NO; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
//        browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
//        browser.autoPlayOnAppear = NO; // Auto-play first video
//        
//        // Present
//        [self.navigationController pushViewController:browser animated:YES];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                                 [NSString stringWithFormat:@"montage.mov"]];
        NSURL *videoURL = [NSURL fileURLWithPath:myPathDocs];
        //filePath may be from the Bundle or from the Saved file Directory, it is just the path for the video
        AVPlayer *player = [AVPlayer playerWithURL:videoURL];
        AVPlayerViewController *playerViewController = [AVPlayerViewController new];
        playerViewController.player = player;
        [playerViewController.player play];//Used to Play On start
        [self presentViewController:playerViewController animated:YES completion:nil];
        [hud hide:YES];

    }];
}

@end
