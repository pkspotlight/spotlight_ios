//
//  ProfileTableViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "ProfileTableViewController.h"
#import <Parse/Parse.h>
#import "ProfilePictureMedia.h"
#import "User.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import <AFNetworking/UIButton+AFNetworking.h>
#import <MBProgressHUD.h>
#import <AFNetworking/UIImageView+AFNetworking.h>


@interface ProfileTableViewController ()
{
    NSString *userName;
    NSString *familyName;
}

@property (strong, nonatomic) NSMutableDictionary *pendingFieldDictionary;
@property (strong, nonatomic) NSArray* userPropertyArray;
@property (strong, nonatomic) NSArray* userPropertyArrayDisplayText;

//@property (weak, nonatomic) IBOutlet UIButton *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageViewFront;


@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) UIImagePickerController* imagePickerController;
@property (strong, nonatomic) ProfilePictureMedia* profilePic;

@end

@implementation ProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.navigationController setNavigationBarHidden:YES];
    self.user = [User currentUser];
     userName = self.user.username;
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
    
    [self loadChildren:nil];
//    self.pendingFieldDictionary = [self newPendingFieldDictionary];
    [self.user[@"profilePic"] fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        self.profilePic = (ProfilePictureMedia*)object;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.profilePic.thumbnailImageFile.url]];
        [self.profilePictureImageViewFront.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.4].CGColor];
        [self.profilePictureImageViewFront.layer setCornerRadius:5];
        [self.profilePictureImageViewFront.layer setBorderWidth:3];
        
        [_profilePictureImageViewFront setClipsToBounds:YES];

        [_profilePictureImageView
         setImageWithURLRequest:request
         placeholderImage:nil
         success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
             
             [self.profilePictureImageView setImage:image];
             [self.profilePictureImageViewFront setImage:image];
         } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
             NSLog(@"fuck thumbnail failure");
         }];

        
     
    }];
    
    //[self.profilePictureImageView.imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
    barButton.tintColor = [UIColor whiteColor];
    
    
    self.navigationItem.rightBarButtonItem = barButton;

    [self.usernameLabel setText:[self.user displayName]];
   
}


- (void)loadChildren:(UIRefreshControl*)refresh {
    PFQuery *query = [self.user.children query];
    NSLog(@"User: %@",self.user.displayName);
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        NSMutableArray *name = [NSMutableArray new];
        for(Child *child in objects){
            NSString *displayName = [NSString stringWithFormat:@"%@ %@",child.firstName ,child.lastName];
            [name addObject:displayName];
        }
    
       
        familyName = [name componentsJoinedByString:@","];
          self.pendingFieldDictionary = [self newPendingFieldDictionary];
        
       
    }];
}

- (NSMutableDictionary *)newPendingFieldDictionary {
    NSMutableDictionary *fieldDict = [NSMutableDictionary dictionary];
    User* user = [User currentUser];
    for (NSString* attribute in self.userPropertyArray) {
        fieldDict[attribute] = user[attribute];
        fieldDict[@"family"] = familyName;
    }
    
    
    [self.tableView reloadData];
    return fieldDict;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)logout {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SpotlightLoginPopUp"];
        
        UIViewController *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"IntroNavigationController"];
        [[UIApplication sharedApplication].delegate.window setRootViewController:controller];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
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
                                                       withValue:self.pendingFieldDictionary[property] isCenter:NO];
        if(indexPath.row == 4){
          
            [[(FieldEntryTableViewCell*)cell valueTextField] setEnabled:NO];
        }
        
        [(FieldEntryTableViewCell*)cell setDelegate:self];
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SendFeedbackCellId" forIndexPath:indexPath];
        
    }
//    } else {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"LogoutCellId" forIndexPath:indexPath];
//
//    }
    return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 1) {
//        [self showFeedbackEmail];
//    } else if(indexPath.section == 2) {
//        NSLog(@"%d",indexPath.section);
//        [self logout];
//    }
//}


- (void)logout:(UIBarButtonItem*)sender {
    [self logout];
}

- (IBAction)showFeedback:(UIButton*)sender {
     [self showFeedbackEmail];
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
    self.profilePictureImageView.image = image;
       self.profilePictureImageViewFront.image = image;
     
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
        if (error) {
            NSString *errorString = [error userInfo][@"error"];
            if(error!= nil){
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:errorString preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
                self.user.username = userName;
                self.pendingFieldDictionary[@"username"] = userName;
                [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }];
                
            }
            
            
        }
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
         self.navigationController.navigationBar.tintColor = [UIColor blueColor];
        [self.navigationController presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}


@end
