//
//  CreateFamilyMemberTableViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 2/8/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import "CreateFamilyMemberTableViewController.h"
#import <AFNetworking/UIButton+AFNetworking.h>
#import <MBProgressHUD.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

#import "User.h"
#import "Child.h"
#import "ProfilePictureMedia.h"

@interface CreateFamilyMemberTableViewController ()

@property (strong, nonatomic) NSMutableDictionary *pendingFieldDictionary;
@property (strong, nonatomic) NSArray* userPropertyArray;
@property (strong, nonatomic) NSArray* userPropertyArrayDisplayText;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageViewFront;
@property (strong, nonatomic) UIImagePickerController* imagePickerController;
@property (weak, nonatomic) IBOutlet UIButton *editPhotoButton;
@property (strong, nonatomic) ProfilePictureMedia* profilePic;

@end

@implementation CreateFamilyMemberTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userPropertyArray = @[ @"firstName", @"lastName", @"homeTown" ];
    self.userPropertyArrayDisplayText = @[ @"First Name", @"Last Name", @"Hometown", @"Family" ];
    
    self.pendingFieldDictionary = [NSMutableDictionary dictionary];
    
//    [self.editPhotoButton.layer setCornerRadius:self.editPhotoButton.bounds.size.width/2];
//    [self.editPhotoButton.layer setBorderWidth:3];
//    [self.editPhotoButton.layer setBorderColor:[UIColor whiteColor].CGColor];
//    [self.editPhotoButton setClipsToBounds:YES];
    
    [self.profilePictureImageViewFront.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.4].CGColor];
    [self.profilePictureImageViewFront.layer setCornerRadius:5];
    [self.profilePictureImageViewFront.layer setBorderWidth:3];
    
    [[UIBarButtonItem appearance]setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                         [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                         [UIFont fontWithName:@"Helvetica" size:14.0], NSFontAttributeName, nil]
                                               forState:UIControlStateNormal];
    
    [_profilePictureImageViewFront setClipsToBounds:YES];
    
    
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userPropertyArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;    
        cell = [tableView dequeueReusableCellWithIdentifier:@"FieldEntryTableViewCell" forIndexPath:indexPath];
        NSString* property = self.userPropertyArray[indexPath.row];
        [(FieldEntryTableViewCell*)cell formatForAttributeString:property
                                                     displayText:self.userPropertyArrayDisplayText[indexPath.row]
                                                       withValue:self.pendingFieldDictionary[property] isCenter:NO];
        [(FieldEntryTableViewCell*)cell setDelegate:self];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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
    if ([self createFamilyMember:error]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        //Show some error
    }
}

- (BOOL)createFamilyMember:(NSError*)error {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Updating Info..."];
    Child* child = [Child new];
    User* user = [User currentUser];
    for (NSString* key in [self.pendingFieldDictionary allKeys]) {
        if (self.pendingFieldDictionary[key] && ![self.pendingFieldDictionary[key] isEqualToString:@""] ) {
            child[key] = self.pendingFieldDictionary[key];
        }
    }
    if (self.profilePic) {
        child.profilePic = self.profilePic;
    }
    [child saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [user.children addObject:child];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [hud hide:YES afterDelay:.5];
        }];
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)infoDict {
    
    NSString *mediaType = [infoDict objectForKey: UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeVideo] ||
        [mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        
        NSURL *videoUrl=(NSURL*)[infoDict objectForKey:UIImagePickerControllerMediaURL];
        NSString *videoPath = [videoUrl path];
        self.profilePic = [[ProfilePictureMedia alloc] initWithVideoPath:videoPath];
        
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [infoDict valueForKey:UIImagePickerControllerOriginalImage];
        self.profilePic = [[ProfilePictureMedia alloc] initWithImage:image];
    }
    [self.profilePic saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"fuck: %@", [error localizedDescription]);
        }
    }];
    PFFile* thumbFile = self.profilePic.thumbnailImageFile;
    [thumbFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        self.profilePictureImageView.image = [UIImage imageWithData:data];
        self.profilePictureImageViewFront.image = [UIImage imageWithData:data];

        [self.editPhotoButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
    }];
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
