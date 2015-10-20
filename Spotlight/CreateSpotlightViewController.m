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
#import <MBProgressHUD.h>

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
        imagePickerController.videoMaximumDuration = 15;
        //imagePickerController.videoQuality = UIImagePickerControllerQualityTypeLow;
        [imagePickerController setAllowsEditing:YES];
        
        self.imagePickerController = imagePickerController;
        [self.navigationController presentViewController:self.imagePickerController animated:YES completion:nil];
        
    }
}

- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.imagePickerController = nil;
}

- (IBAction)cancelButtonPressed:(id)sender {
//    [self.spotlight deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//        
//    }];
//    [self.navigationController dismissViewControllerAnimated:YES completion:^{
//        
//    }];
}
- (IBAction)saveButtonPressed:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Creating Spotlight..."];
    self.spotlight[@"title"] = self.titleTextField.text;
    PFUser* user = [PFUser currentUser];
    PFRelation *participantRelation = [self.spotlight relationForKey:@"spotlightParticipant"];
    [participantRelation addObject:user];
    [self.spotlight saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self performSegueWithIdentifier:@"DoneCreatingSegue" sender:sender];
            //[self performSelector:@selector(dismissView:) withObject:hud afterDelay:1.5];
        }
        if (error) {
            NSLog(@"fuck: %@", [error localizedDescription]);
        }
    }];
}

- (void)dismissView:(MBProgressHUD*)hud {
    [hud hide:YES afterDelay:1.5];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{

    }];
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
    [self.mediaFiles addObject:media];
    media[@"parent"] = self.spotlight;
    [media saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"fuck: %@", [error localizedDescription]);
        }
    }];
    PFFile* thumbFile = media.thumbnailImageFile;
    [thumbFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        [self.mediaView setImage:[UIImage imageWithData:data]];
    }];
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
