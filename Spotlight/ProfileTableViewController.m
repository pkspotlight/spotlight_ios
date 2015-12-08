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

@interface ProfileTableViewController ()

@property (strong, nonatomic) NSMutableDictionary *pendingFieldDictionary;
@property (strong, nonatomic) NSArray* userPropertyArray;

@property (weak, nonatomic) IBOutlet UIButton *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) UIImagePickerController* imagePickerController;
@property (strong, nonatomic) ProfilePictureMedia* profilePic;

@end

@implementation ProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = [User currentUser];
    
    self.userPropertyArray = @[ @"firstName", @"lastName" ];
    self.pendingFieldDictionary = [self newPendingFieldDictionary];
    
    [self.user[@"profilePic"] fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        self.profilePic = (ProfilePictureMedia*)object;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.profilePic.thumbnailImageFile.url]];
        
        [self.profilePictureImageView setImageForState:UIControlStateNormal withURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
            [self.profilePictureImageView setImage:image forState:UIControlStateNormal];
        } failure:^(NSError * _Nonnull error) {
            
        }];
    }];
    
    [self.profilePictureImageView.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.usernameLabel setText:self.user.username];
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
    // Dispose of any resources that can be recreated.
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
                                                       withValue:self.pendingFieldDictionary[property]];
        [(FieldEntryTableViewCell*)cell setDelegate:self];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LogoutCellId" forIndexPath:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self logout];
}
- (IBAction)editPictureButtonPressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.delegate = self;
        imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
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
    self.user[@"profilePic"] = self.profilePic;
    [self.user saveInBackground];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
//    if ([self savePendingChangesToAccount:&error]) {
//        [self dismissViewControllerAnimated:YES completion:nil];
//    } else {
//        //Show some error
//    }
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
        imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
        imagePickerController.videoMaximumDuration = 15;
        [imagePickerController setAllowsEditing:YES];
        
        self.imagePickerController = imagePickerController;
        [self.navigationController presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}


@end
