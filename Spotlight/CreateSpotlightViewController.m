//
//  CreateSpotlightViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 10/19/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "CreateSpotlightViewController.h"
#import "Spotlight.h"
#import "SpotlightMedia.h"
#import <MobileCoreServices/UTCoreTypes.h>


@interface CreateSpotlightViewController ()

@property (strong, nonatomic) Spotlight *spotlight;
@property (strong, nonatomic) UIImagePickerController* imagePickerController;

@property (strong, nonatomic) NSMutableArray *mediaFiles;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIImageView *mediaView;

@end

@implementation CreateSpotlightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.spotlight = [Spotlight object];
    self.mediaFiles = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addMediaButtonPressed:(id)sender {
    
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        //imagePickerController.imagePickerDelegate = self;
        imagePickerController.delegate = self;
        imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeLow;
        [imagePickerController setAllowsEditing:YES];
        
        self.imagePickerController = imagePickerController;
        [self.navigationController presentViewController:self.imagePickerController animated:YES completion:nil];
        
    }
}

- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:YES completion:nil];
    //
    //    if ([self.capturedImages count] > 0)
    //    {
    //        if ([self.capturedImages count] == 1)
    //        {
    //            // Camera took a single picture.
    //            [self.imageView setImage:[self.capturedImages objectAtIndex:0]];
    //        }
    //        else
    //        {
    //            // Camera took multiple pictures; use the list of images for animation.
    //            self.imageView.animationImages = self.capturedImages;
    //            self.imageView.animationDuration = 5.0;    // Show each captured photo for 5 seconds.
    //            self.imageView.animationRepeatCount = 0;   // Animate forever (show all photos).
    //            [self.imageView startAnimating];
    //        }
    //
    //        // To be ready to start again, clear the captured images array.
    //        [self.capturedImages removeAllObjects];
    //    }
    //
    self.imagePickerController = nil;
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.spotlight deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
    }];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)saveButtonPressed:(id)sender {
    self.spotlight[@"title"] = self.titleTextField.text;
    PFUser* user = [PFUser currentUser];
    PFRelation *participantRelation = [self.spotlight relationForKey:@"spotlightParticipant"];
    [participantRelation addObject:user];
    [self.spotlight saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
    }];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
//- (void)elcImagePickerController:(ELCImagePickerController *)picker
//   didFinishPickingMediaWithInfo:(NSArray *)infoArray {

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)infoDict {
    
    //   for (NSDictionary* infoDict in infoArray) {
    SpotlightMedia *media;
    NSString *mediaType = [infoDict objectForKey: UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeVideo] ||
        [mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        
        NSURL *videoUrl=(NSURL*)[infoDict objectForKey:UIImagePickerControllerMediaURL];
        NSString *moviePath = [videoUrl path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            NSData *videoData = [[NSFileManager defaultManager] contentsAtPath:moviePath];
            media = [[SpotlightMedia alloc] initWithVideoData:videoData];
            
        }
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [infoDict valueForKey:UIImagePickerControllerOriginalImage];
        media = [[SpotlightMedia alloc] initWithImage:image];
        [self.mediaView setImage:image];
    }
    [self.mediaFiles addObject:media];
    media[@"parent"] = self.spotlight;
    //    }
    
    //    [self.capturedImages addObject:image];
    
    [self finishAndUpdate];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}



@end
