//
//  FriendProfileViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 12/1/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "FriendProfileViewController.h"
#import "FriendsTableViewController.h"
#import "SpotlightFeedViewController.h"
#import "SpotlightDataSource.h"
#import "TeamsTableViewController.h"
#import "User.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "Child.h"
#import "ProfilePictureMedia.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface FriendProfileViewController()

@property (weak, nonatomic) IBOutlet UIImageView *friendImageView;
@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;
@property (weak, nonatomic) IBOutlet UIView *teamsContainerView;
@property (weak, nonatomic) IBOutlet UIButton *editChildProfile;
@property (weak, nonatomic) IBOutlet UIView *spotlightsContainerView;
@property (weak, nonatomic) IBOutlet UIView *familyContainerView;
@property (strong, nonatomic) UIImagePickerController* imagePickerController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) ProfilePictureMedia* profilePic;


@property (assign, nonatomic) BOOL hasFamily;

@end

@implementation FriendProfileViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.friendImageView.layer setCornerRadius:self.friendImageView.bounds.size.width/2];
    [self.friendImageView.layer setBorderWidth:3];
    [self.friendImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.friendImageView setClipsToBounds:YES];
    if (self.user) {
        [self formatForUser];
    } else {
        [self formatForChild];
    }
}

- (IBAction)segmentControllerValueChanged:(UISegmentedControl*)sender {
    if( sender.selectedSegmentIndex == 0) {
        [UIView animateWithDuration:.5
                         animations:^{
                             [self.spotlightsContainerView setAlpha:1];
                             [self.teamsContainerView setAlpha:0];
                             [self.familyContainerView setAlpha:0];
                         }];
    } else if( sender.selectedSegmentIndex == 1) {
        [UIView animateWithDuration:.5
                         animations:^{
                             [self.teamsContainerView setAlpha:1];
                             [self.spotlightsContainerView setAlpha:0];
                             [self.familyContainerView setAlpha:0];
                         }];
    } else {
        [UIView animateWithDuration:.5
                         animations:^{
                             [self.spotlightsContainerView setAlpha:0];
                             [self.teamsContainerView setAlpha:0];
                             [self.familyContainerView setAlpha:1];
                         }];
        
    }
}

- (void)formatWithName:(NSString*)name profilePicture:(ProfilePictureMedia*)profilePic {
    [self.friendNameLabel setText:name];
    [self.friendImageView cancelImageRequestOperation];
    [profilePic fetchIfNeeded];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:profilePic.thumbnailImageFile.url]];
    [self.friendImageView
     setImageWithURLRequest:request
     placeholderImage:nil
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
         [self.friendImageView setImage:image];
     } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
         NSLog(@"fuck thumbnail failure");
     }];
    [self.user.children.query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects && [objects count] > 0) {
            self.hasFamily = YES;
            [self.segmentedControl insertSegmentWithTitle:@"Family" atIndex:2 animated:NO];
            [self performSegueWithIdentifier:@"EmbedFamilySegue" sender:nil];
        }
    }];
}

- (void)formatForUser {
     self.editChildProfile.hidden = YES;
    [self formatWithName:[self.user displayName] profilePicture:self.user.profilePic];
}

- (void)formatForChild {
    self.editChildProfile.hidden = NO;
    [self formatWithName:[self.child displayName] profilePicture:self.child.profilePic];
}
     
-(BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"friendTeamsEmbedSegue"]) {
        if (self.user) {
            [(TeamsTableViewController*)[segue destinationViewController] setUser:self.user];
        } else {
            [(TeamsTableViewController*)[segue destinationViewController] setChild:self.child];
        }
    } else if ([segue.identifier isEqualToString:@"EmbedSpotlightSegue"]){
        SpotlightDataSource* datasource;
        if (self.user) {
            datasource = [[SpotlightDataSource alloc] initWithUser:self.user];
        } else {
            datasource = [[SpotlightDataSource alloc] initWithChild:self.child];
        }
        [(SpotlightFeedViewController*)[segue destinationViewController] setDataSource:datasource];
    } else if (self.hasFamily){
        [(FriendsTableViewController*)[segue destinationViewController] setUser:self.user];
        [(FriendsTableViewController*)[segue destinationViewController] setJustFamily:YES];
    }
}

- (IBAction)editPictureButtonPressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.delegate = self;
        imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
        imagePickerController.videoMaximumDuration = 15;
        [imagePickerController setAllowsEditing:YES];
        
        self.imagePickerController = imagePickerController;
        [self.navigationController.tabBarController presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)infoDict {
    
    UIImage *image = [infoDict valueForKey:UIImagePickerControllerOriginalImage];
    self.profilePic = [[ProfilePictureMedia alloc] initWithImage:image];
    [self.friendImageView setImage:image];
    [self.profilePic saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
    }];
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    self.child.profilePic = self.profilePic;
    [self.child saveInBackground];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return (![identifier isEqualToString:@"EmbedFamilySegue"] || self.hasFamily);
}

@end
