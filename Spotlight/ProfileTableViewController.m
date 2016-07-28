//
//  ProfileTableViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "ProfileTableViewController.h"
#import "Parse.h"
#import "ProfilePictureMedia.h"
#import "User.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import <AFNetworking/UIButton+AFNetworking.h>
#import <MBProgressHUD.h>


@interface ProfileTableViewController ()

@property (strong, nonatomic) NSMutableDictionary *pendingFieldDictionary;
@property (strong, nonatomic) NSArray* userPropertyArray;
@property (strong, nonatomic) NSArray* userPropertyArrayDisplayText;

@property (weak, nonatomic) IBOutlet UIButton *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) UIImagePickerController* imagePickerController;
@property (strong, nonatomic) ProfilePictureMedia* profilePic;

@end

@implementation ProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = [User currentUser];
    self.userPropertyArray = @[ @"username",
                                @"firstName",
                                @"lastName",
                                @"homeTown",
                                @"family" ];
    self.userPropertyArrayDisplayText = @[ @"Username",
                                           @"First Name",
                                           @"Last Name",
                                           @"Hometown",
                                           @"Family" ];
    self.pendingFieldDictionary = [self newPendingFieldDictionary];
    [self.user[@"profilePic"] fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        self.profilePic = (ProfilePictureMedia*)object;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.profilePic.thumbnailImageFile.url]];
        
        [self.profilePictureImageView setImageForState:UIControlStateNormal withURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
            [self.profilePictureImageView setImage:image forState:UIControlStateNormal];
        } failure:nil];
    }];
    
    [self.profilePictureImageView.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.usernameLabel setText:[self.user displayName]];
    [self.profilePictureImageView.layer setCornerRadius:self.profilePictureImageView.bounds.size.width/2];
    [self.profilePictureImageView.layer setBorderWidth:3];
    [self.profilePictureImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.profilePictureImageView setClipsToBounds:YES];
}

- (NSMutableDictionary *)newPendingFieldDictionary {
    NSMutableDictionary *fieldDict = [NSMutableDictionary dictionary];
    User* user = [User currentUser];
    for (NSString* attribute in self.userPropertyArray) {
        fieldDict[attribute] = user[attribute];
    }
    return fieldDict;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)logout {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        
        UIViewController *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"IntroNavigationController"];
        [[UIApplication sharedApplication].delegate.window setRootViewController:controller];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? self.userPropertyArray.count : 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FieldEntryTableViewCell" forIndexPath:indexPath];
        NSString* property = self.userPropertyArray[indexPath.row];
        [(FieldEntryTableViewCell*)cell formatForAttributeString:property
                                                     displayText:self.userPropertyArrayDisplayText[indexPath.row]
                                                       withValue:self.pendingFieldDictionary[property]];
        [(FieldEntryTableViewCell*)cell setDelegate:self];
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SendFeedbackCellId" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LogoutCellId" forIndexPath:indexPath];

    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [self showFeedbackEmail];
    } else {
        [self logout];
    }
}

- (void)showFeedbackEmail {
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"Spotlight Feedback"];
        [mail setToRecipients:@[@"ryan@myspotlight.me"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
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
    [self.profilePictureImageView setImage:image forState:UIControlStateNormal];
    [self.profilePic saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

    }];
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    self.user.profilePic = self.profilePic;
    [self.user saveInBackground];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Mail Composer Methods



- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}



#pragma mark - Delegate Methods

- (void)accountTextFieldCell:(FieldEntryTableViewCell *)cell didChangeToValue:(NSString *)text {
    self.pendingFieldDictionary[cell.attributeString] = text;
}

- (void)accountTextFieldCellDidReturn:(FieldEntryTableViewCell *)cell {
    NSIndexPath *path = [self indexPathFollowingAttribute:cell.attributeString];
    if (path) {
        FieldEntryTableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        if (cell) {
            [cell focusTextField];
        }
    } else {
        if ([self.view endEditing:NO]) {
            [self saveAccountPressed:nil];
        }
    }
}

- (NSIndexPath *)indexPathFollowingAttribute:(NSString*)attribute{
    NSInteger index = [self.userPropertyArray indexOfObject:attribute];
    NSInteger nextIndex = index + 1;
    if (nextIndex < self.userPropertyArray.count) {
        return [NSIndexPath indexPathForRow:nextIndex inSection:0];
    }
    return nil;
}

- (IBAction)saveAccountPressed:(id)sender {
    NSError *error;
    [self.view endEditing:NO];
    if ([self savePendingChangesToUser:error]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        //Show some error
    }
}

- (BOOL)savePendingChangesToUser:(NSError*)error {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Updating Info..."];
    for (NSString* key in [self.pendingFieldDictionary allKeys]) {
        self.user[key] = self.pendingFieldDictionary[key];
    }
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [hud hide:YES afterDelay:.5];
    }];
    return YES;
}


- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editPhotoButtonPressed:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.delegate = self;
        imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
        imagePickerController.videoMaximumDuration = 15;
        [imagePickerController setAllowsEditing:YES];
        
        self.imagePickerController = imagePickerController;
        [self.navigationController presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}


@end
