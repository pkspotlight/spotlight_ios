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
@property (weak, nonatomic) IBOutlet UITextView *participantTextView;

@end

@implementation CreateSpotlightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.spotlight = [Spotlight object];
    self.mediaFiles = [NSMutableArray array];
    [self.participantTextView setText:[NSString stringWithFormat:@"Participants:  %@", [[PFUser currentUser] username]]];
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
        imagePickerController.delegate = self;
        imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
        imagePickerController.videoMaximumDuration = 15;
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
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)saveButtonPressed:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Creating Spotlight..."];
    self.spotlight.title = self.titleTextField.text;
    PFUser* user = [PFUser currentUser];
    PFRelation *participantRelation = [self.spotlight relationForKey:@"spotlightParticipant"];
    [participantRelation addObject:user];
    [self.spotlight setCreatorName:user.username];
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

- (IBAction)addParticipantButtonPressed:(id)sender {
//    CNContactPickerViewController *contactVC = [[CNContactPickerViewController alloc] init];
    //    [contactVC setPredicateForEnablingContact:[NSPredicate predicateWithFormat:@"emailAddresses != nil"]];
    //    [contactVC setDelegate:self];
    //    [self.navigationController presentViewController:contactVC animated:YES completion:nil];
    
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:@"Enter email of participant"
                                message:nil
                                preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setKeyboardType:UIKeyboardTypeEmailAddress];
    }];
    [alert addAction:[UIAlertAction
                      actionWithTitle:@"Add Participant"
                      style:UIAlertActionStyleDefault
                      handler:^(UIAlertAction * _Nonnull action) {
                          PFQuery *query = [PFUser query];
                          [query whereKey:@"username" equalTo:alert.textFields[0].text];
                          [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                              if (object) {
                                  PFRelation *participantRelation = [self.spotlight relationForKey:@"spotlightParticipant"];
                                  [participantRelation addObject:object];
                                [self.participantTextView setText:[NSString stringWithFormat:@"%@, %@", self.participantTextView.text, [(PFUser*)object username]]];
                              }else {
                                  UIAlertController* noUserAlert = [UIAlertController
                                                              alertControllerWithTitle:@"User does not exist"
                                                              message:nil
                                                              preferredStyle:UIAlertControllerStyleAlert];
                                  [noUserAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                                  [self presentViewController:noUserAlert animated:YES completion:nil];
                                  
                              }

                          }];

                      }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)infoDict {
    
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

#pragma mark - ContactPickerDelegate Methods


- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact *> *)contacts {
    for (CNContact *contact in contacts) {
        NSLog(@"%@ ",contact.emailAddresses);
    }
}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    
}



@end
