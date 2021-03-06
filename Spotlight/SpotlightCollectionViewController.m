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
#import "User.h"
#import "MontageCreator.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MBProgressHUD.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "PECropViewController.h"
#import "SpotlightTaggedParticipantView.h"


@interface SpotlightCollectionViewController ()<PECropViewControllerDelegate,PassTitleAndParticipantProtocol>{
    id infoMedia;
    BOOL isCamera;
    BOOL isView;
    
}

@property (strong, nonatomic) NSArray* mediaList;
@property (strong, nonatomic) UIImagePickerController* imagePickerController;
@property (assign, nonatomic) BOOL isShowingMontage;
@property (weak, nonatomic) IBOutlet UIButton *viewSpotlightButton;
@property (strong, nonatomic) NSMutableArray* teamsMemberArray;
@property (strong, nonatomic) NSMutableArray* teamsSpectMemberArray;

@property (weak, nonatomic) IBOutlet UIButton *shareSpotlightButton;

@property (strong, nonatomic) MWPhotoBrowser *browser;
@property (strong, nonatomic)MPMediaPickerController* musicMediaPicker;


@end

@implementation SpotlightCollectionViewController

static NSString * const reuseIdentifier = @"SpotlightMediaCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    _teamsMemberArray = [NSMutableArray new];
    _teamsSpectMemberArray = [NSMutableArray new];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    [self getParticipantArrayOfTeam];
    [refreshControl beginRefreshing];
    
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake((self.view.frame.size.width-140)/2, 12, 140, 40)];
    label.numberOfLines = 3;
    
    
    label.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    
    label.minimumFontSize = 13.0f;
    
    //label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor =[UIColor whiteColor];
    
    if([_spotlight.spotlightTitle length]<=0){
        label.text = @"Spotlight";
    }else{
        label.text = _spotlight.spotlightTitle;
    }
    self.navigationItem.titleView = label;
    
    [self refresh:refreshControl];
}

-(void)getParticipantArrayOfTeam{
    [_teamsMemberArray removeAllObjects];
    [_teamsSpectMemberArray removeAllObjects];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Child"];
    [query whereKey:@"teams" equalTo:self.spotlight.team];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        for(Child *child in objects){
            if([self.spotlight.team.spectatorsArray containsObject:child.objectId]){
                [_teamsSpectMemberArray addObject:child];
            }else{
                [_teamsMemberArray addObject:child];
            }
        }
        PFQuery *query1 = [PFQuery queryWithClassName:@"_User"];
        [query1 whereKey:@"teams" equalTo:self.spotlight.team];
        
        [query1 findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            for(User *user in objects){
                if([self.spotlight.team.spectatorsArray containsObject:user.objectId]){
                    [_teamsSpectMemberArray addObject:user];
                }else{
                    [_teamsMemberArray addObject:user];
                    
                }
            }
        }];
    }];
    
}

- (void)refresh:(UIRefreshControl*)refresh {
    [self.spotlight allMedia:^(NSArray *media, NSError *error) {
        self.mediaList = [self getSortedArray:media];
        //  self.mediaList = media;
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
    
    CGFloat width = self.collectionView.bounds.size.width/3;
    return CGSizeMake(width, width);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Create browser (must be done each time photo browser is
    // displayed. Photo browser objects cannot be re-used)
    self.browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [self.browser setTeamMembers:self.teamsMemberArray];
    
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
    [self.navigationController pushViewController:self.browser animated:YES];
}

-(void)photoBrowser:(MWPhotoBrowser *)photoBrowser deletePhotoAtIndex:(NSUInteger)index {
    
    [self.navigationController popViewControllerAnimated:YES];
    SpotlightMedia *media = self.mediaList[index];
    [media deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self refresh:nil];
    }];
}


-(void)editPhotoAtIndex:(NSUInteger)index withImage:(UIImage *)image
{
    if( self.mediaList.count > index && image)
    {
        SpotlightMedia *media = self.mediaList[index];
        if(!media.isVideo) {
            
            PECropViewController *controller = [[PECropViewController alloc] init];
            controller.delegate = self;
            controller.image = image;
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            [self presentViewController:navigationController animated:YES completion:NULL];
        }
    }
    
}

-(void)photoBrowser:(MWPhotoBrowser *)photoBrowser shareMediaForVideo:(NSUInteger)index{
    SpotlightMedia *media = self.mediaList[index];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window]animated:YES];
    [hud setLabelText:@"Please Wait..."];
    [[MontageCreator sharedCreator] createMontageWithMedia:@[media]
                                                 songTitle:nil
                                                  assetURL:nil
                                                   isShare:YES
                                                completion:^(AVPlayerItem *item, NSURL *fileURL) {
                                                    
                                                    UIActivityViewController* AVC =  [[UIActivityViewController alloc] initWithActivityItems:@[fileURL, @""] applicationActivities:nil];
                                                    [self presentViewController:AVC
                                                                       animated:YES
                                                                     completion:^{
                                                                         [hud hide:YES];
                                                                     }];
                                                }];
}

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage{
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
    SpotlightMedia* media = self.mediaList[self.browser.currentIndex];
    media.mediaFile = [PFFile fileWithName:@"image.png" data:UIImageJPEGRepresentation(croppedImage, 1.0)];
    media.thumbnailImageFile = [PFFile fileWithName:@"image.png" data:UIImageJPEGRepresentation(croppedImage, 0.5)];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:YES];
    [hud setLabelText:@"Updating image..."];
    
    [media saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.browser reloadData];
        [self.collectionView reloadData];
        [hud hide:YES];
    }];
    
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}


-(void)cropBtnClicked:(NSUInteger)currentIndex withImage:(UIImage *)image
{
    [self editPhotoAtIndex:currentIndex withImage:image];
}


-(void)photoBrowser:(MWPhotoBrowser *)photoBrowser likePhotoAtIndex:(NSUInteger)index {
    SpotlightMedia *media = self.mediaList[index];
    PFQuery* query = [media.likes query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        for (User* user in objects) {
            if ([user.objectId isEqualToString:[[User currentUser] objectId]]) {
                [media unlikeInBackgroundFromUser:[User currentUser] completion:^{
                    [self photoBrowser:self.browser populateLikesForPhotoAtIndex:index];
                }];
                return;
            }
        }
        [media likeInBackgroundFromUser:[User currentUser] completion:^{
            [self photoBrowser:self.browser populateLikesForPhotoAtIndex:index];
        }];
    }];
}

-(void)photoBrowser:(MWPhotoBrowser *)photoBrowser populateLikesForPhotoAtIndex:(NSUInteger)index {
    SpotlightMedia *media = self.mediaList[index];
    [media likeCountWithCompletion:^(NSInteger likes) {
        //  [self.browser populateLikeCount:likes atIndex:index];
    }];
}

-(void)photoBrowser:(MWPhotoBrowser *)photoBrowser addParticipants:(NSArray*)participants withTitle:(NSString*)title atIndex:(NSUInteger)index {
    SpotlightMedia *media = self.mediaList[index];
    NSMutableArray *childArray = [NSMutableArray new];
    NSMutableArray *userArray = [NSMutableArray new];
    for(User *user in participants) {
        NSString *userName = [NSString stringWithFormat:@"%@ %@",user.firstName
                              ,user.lastName];
        [userArray addObject:userName];
    }
    NSMutableArray *combinedArray = [userArray arrayByAddingObjectsFromArray:childArray].mutableCopy;
    
    NSSet *distinctSet = [NSSet setWithArray:combinedArray];
    NSMutableArray *participantNameArray = [distinctSet allObjects].mutableCopy;
    [media setParticipantArray:participantNameArray];
    [media setTitle:title];
    __weak SpotlightCollectionViewController* tempSelf = self;
    [media saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [tempSelf.browser reloadData];
        [tempSelf refreshSpotlightCollectionImages];
    }];
}


-(void)addParticipants:(NSArray *)participant withTitle:(NSString *)title{
    
    NSMutableArray *childArray = [NSMutableArray new];
    NSMutableArray *userArray = [NSMutableArray new];
    for(Child *child in participant) {
        NSString *name = [NSString stringWithFormat:@"%@ %@",child.firstName
                          ,child.lastName];
        [childArray addObject:name];
    }
    for(User *user in participant) {
        NSString *userName = [NSString stringWithFormat:@"%@ %@",user.firstName
                              ,user.lastName];
        [userArray addObject:userName];
    }
    NSMutableArray *combinedArray = [userArray arrayByAddingObjectsFromArray:childArray].mutableCopy;
    
    NSSet *distinctSet = [NSSet setWithArray:combinedArray];
    NSMutableArray *participantArray = [distinctSet allObjects].mutableCopy;
    
    if(isCamera){
        [self saveImageWithMediaInfoVideo:infoMedia participants:participantArray title:title];
    }else{
        [self saveImageWithMediaInfo:infoMedia participants:participantArray title:title];
    }
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)addMediaButtonPressed:(id)sender {
    
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
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
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

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.isShowingMontage ? 1 : self.mediaList.count;
}

- (NSArray *)photoBrowser:(MWPhotoBrowser *)photoBrowser participantNamesAtIndex:(NSUInteger)index {
    SpotlightMedia *media = self.mediaList[index];
    return media.participantArray;
}

- (NSString*)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
    SpotlightMedia *media = self.mediaList[index];
    return media.title;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (self.isShowingMontage) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                                 [NSString stringWithFormat:@"montage.mov"]];
        MWPhoto *video = [MWPhoto videoWithURL:[NSURL URLWithString:myPathDocs]];
        video.videoURL = [NSURL URLWithString:myPathDocs];
    } else {
        if (index < self.mediaList.count) {
            return [self mwphotoForSpotlightMedia:self.mediaList[index]];
        }
    }
    return nil;
}


- (MWPhoto*)mwphotoForSpotlightMedia:(SpotlightMedia*)media {
    MWPhoto *mwMedia;
    if (media.isVideo) {
        mwMedia= [MWPhoto photoWithURL:[NSURL URLWithString:media.thumbnailImageFile.url]];
        mwMedia.videoURL = [NSURL URLWithString:media.mediaFile.url];
    } else {
        mwMedia =[MWPhoto photoWithURL:[NSURL URLWithString:media.mediaFile.url]];
    }
    if (media.title) {
        mwMedia.caption = media.title;
    }
    return mwMedia;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)infoDict {
    isCamera = YES;
    infoMedia = infoDict;
    [self dismissViewControllerAnimated:YES completion:^{
        [self addSpotlightParticipantPopUp];
    }];
}

- (void)saveImageWithMediaInfoVideo:(NSDictionary<NSString *,id> *)infoDict participants:participantArray title:(NSString*)title{
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
       // NSString *videoPath = [videoUrl path];
        media = [[SpotlightMedia alloc] initWithVideoPath:videoUrl];
        media.timeStamp =timestamp;
        media.participantArray = participantArray;
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [infoDict valueForKey:UIImagePickerControllerOriginalImage];
        media = [[SpotlightMedia alloc] initWithImage:image];
    }
    if (title) {
        media.title = title;
    }
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Adding Media..."];
    media[@"parent"] = self.spotlight;
    [media saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"fuck: %@", [error localizedDescription]);
        } else {
            [self.spotlight allMedia:^(NSArray *media, NSError *error) {
                self.mediaList = [self getSortedArray:media];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
                [self.collectionView reloadData];
                [hud hide:YES];
            }];
        }
    }];
    self.imagePickerController = nil;
}

- (void)saveImageWithMediaInfo:(NSArray *)info participants:participantArray title:(NSString*)title{
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
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * avasset, AVAudioMix * audioMix, NSDictionary * info) {

                AVURLAsset *asset = (AVURLAsset *)avasset;
                NSURL *url = asset.URL;
                media = [[SpotlightMedia alloc] initWithVideoPath:url];
                media.timeStamp = timestamp;
                media.participantArray = participantArray;
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
                        } else {
                            [self.spotlight allMedia:^(NSArray *media, NSError *error) {
                                self.mediaList = [self getSortedArray:media];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
                                [self.collectionView reloadData];
                                [hud hide:YES];
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
            media.participantArray = participantArray;
            
            if (title) {
                media.title = title;
            }
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [hud setLabelText:@"Adding Media..."];
            media[@"parent"] = self.spotlight;
            [media saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (error) {
                    [hud hide:YES];
                    
                    NSLog(@"fuck: %@", [error localizedDescription]);
                } else {
                    [self.spotlight allMedia:^(NSArray *media, NSError *error) {
                        //self.mediaList = media;
                        self.mediaList = [self getSortedArray:media];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
                        [self.collectionView reloadData];
                        [hud hide:YES];
                    }];
                }
            }];
            
        }
    }
    self.imagePickerController = nil;
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info{
    [self dismissViewControllerAnimated:YES completion:^{
        infoMedia = info;
        isCamera = NO;
        if(info.count>1){
            
            [self addSpotlightParticipantPopUp];
        } else{
            
            [self addSpotlightParticipantPopUp];
        }
    }];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker{
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


-(NSArray*)getSortedArray:(NSArray*)arr{
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
    NSArray *sortedArray = [arr sortedArrayUsingDescriptors:descriptors];
    return sortedArray;
}

#pragma mark - Montage Functions

- (IBAction)viewMontageButtonPressed:(id)sender {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Select your background music"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Choose Music from Device"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                isView = true;
                                                [self openMedia];
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cool Kids"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self createMontageWithSongTitle:@"DT_TheDuff_CoolKids_INST130" share:NO AssetURL:nil];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Disney Funk"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self createMontageWithSongTitle:@"TB - Disney Funk 124bpm" share:NO AssetURL:nil];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Every Single Night"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self createMontageWithSongTitle:@"DT_TheDUFF_EverySingleNight_INST_125" share:NO AssetURL:nil];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ready 2 Go"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self createMontageWithSongTitle:@"DT_TheDuff_Ready2Go_128_INST" share:NO AssetURL:nil];
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"No Music"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self createMontageWithSongTitle:nil share:NO AssetURL:nil];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)addSpotlightParticipantPopUp{
    SpotlightTaggedParticipantView *spotlightParticipantView = [[SpotlightTaggedParticipantView alloc] initWithParticipants:_teamsMemberArray selectedParticipants:@[] title:nil];
    spotlightParticipantView.delegate = self;
    CGRect frameRect =spotlightParticipantView.frame;
    frameRect.size.width = [UIScreen mainScreen].bounds.size.width;
    frameRect.size.height = [UIScreen mainScreen].bounds.size.height;
    spotlightParticipantView.frame = frameRect;
    
    [ [[UIApplication sharedApplication].delegate window] addSubview:spotlightParticipantView];
    spotlightParticipantView.translatesAutoresizingMaskIntoConstraints = true;
}

- (IBAction)shareMontageButtonPressed:(id)sender {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Select your background music"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Choose Music from your device"
                      
                                              style:UIAlertActionStyleDefault
                      
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                isView = false;
                                                [self openMedia];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cool Kids"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self createMontageWithSongTitle:@"DT_TheDuff_CoolKids_INST130" share:YES AssetURL:nil];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Disney Funk"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self createMontageWithSongTitle:@"TB - Disney Funk 124bpm" share:YES AssetURL:nil];
                                                }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Every Single Night"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self createMontageWithSongTitle:@"DT_TheDUFF_EverySingleNight_INST_125"  share:YES AssetURL:nil];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ready 2 Go"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self createMontageWithSongTitle:@"DT_TheDuff_Ready2Go_128_INST" share:YES AssetURL:nil];
                                            }]];
    
    
    [alert addAction:[UIAlertAction actionWithTitle:@"No Music"
                      
                                              style:UIAlertActionStyleDefault
                      
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                                [self createMontageWithSongTitle:nil share:YES AssetURL:nil];
                                                
                                            }]];
    
    
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)createMontageWithSongTitle:(NSString*)songTitle share:(BOOL)shouldShare AssetURL:(NSURL *)assetURL{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Creating Reel..."];
    
    if (shouldShare) {
        [[MontageCreator sharedCreator] createMontageWithMedia:[self.mediaList copy] songTitle:songTitle assetURL:assetURL isShare:YES completion:^(AVPlayerItem *item, NSURL *fileURL) {
            
            UIActivityViewController* AVC =  [[UIActivityViewController alloc] initWithActivityItems:@[fileURL, @""] applicationActivities:nil];
            [self presentViewController:AVC
                               animated:YES
                             completion:^{
                                 [hud hide:YES];
                             }];
        }];
    } else {
        
        [[MontageCreator sharedCreator] createMontageWithMedia:[self.mediaList copy] songTitle:songTitle assetURL:assetURL  isShare:NO completion:^(AVPlayerItem *item, NSURL *fileURL) {
            AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
            AVPlayerViewController* VC = [[AVPlayerViewController alloc] init];
            
            [VC setShowsPlaybackControls:YES];
            [VC setPlayer:player];
            [self presentViewController:VC
                               animated:YES
                             completion:^{
                                 [VC.player play];
                             }];
            [hud hide:YES];
        }];
    }
}

-(void)openMedia {

    switch ([MPMediaLibrary authorizationStatus]){
        case MPMediaLibraryAuthorizationStatusDenied: {
            NSLog(@"denied");
            [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
                if ([MPMediaLibrary authorizationStatus] == MPMediaLibraryAuthorizationStatusAuthorized){
                    [self pickTheMusic];
                }
            }];
            break;
        }
        case MPMediaLibraryAuthorizationStatusAuthorized:
            NSLog(@"authorized");
            [self pickTheMusic];
            break;
        case MPMediaLibraryAuthorizationStatusRestricted: {
            NSLog(@"restricted");
            [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
                if ([MPMediaLibrary authorizationStatus] == MPMediaLibraryAuthorizationStatusAuthorized){
                    [self pickTheMusic];
                }
            }];
            break;
        }
        case MPMediaLibraryAuthorizationStatusNotDetermined:{
            NSLog(@"not det");
            [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
                if ([MPMediaLibrary authorizationStatus] == MPMediaLibraryAuthorizationStatusAuthorized){
                    [self pickTheMusic];
                }
            }];
            break;
        }
    }
}

- (void)pickTheMusic{
    self.musicMediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    self.musicMediaPicker.delegate = self;
    self.musicMediaPicker.allowsPickingMultipleItems = NO;
    self.musicMediaPicker.showsCloudItems = NO;
    [self.navigationController presentViewController:self.musicMediaPicker animated:YES completion:nil];
}

- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self exportAssetAsSourceFormat:[[mediaItemCollection items] objectAtIndex:0]];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)exportAssetAsSourceFormat:(MPMediaItem *)item {
    
    NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
    
    if(isView){
        [self createMontageWithSongTitle:nil share:NO AssetURL:assetURL];
    }else{
        [self createMontageWithSongTitle:nil share:YES AssetURL:assetURL];
    }
}

- (IBAction)reorderSpotlightController:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ReorderSpolightImagesTableViewController *reorderRequestController = [storyboard instantiateViewControllerWithIdentifier:@"ReorderSpotlight"];
    reorderRequestController.mediaSpotlightList = [self.mediaList mutableCopy];
    reorderRequestController.delegate = self;
    [self.navigationController pushViewController:reorderRequestController animated:YES];
    
}

-(void)refreshSpotlightCollectionImages{
    [self refresh:nil];
}

-(void)deleteMyFile:(NSString *)path{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        NSError *deleteErr = nil;
        
        [[NSFileManager defaultManager] removeItemAtPath:path error:&deleteErr];
        
        if (deleteErr) {
            NSLog (@"Can't delete %@: %@", path, deleteErr);
        }
    }
}


@end
