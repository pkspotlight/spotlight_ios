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

#import "User.h"

@interface CreateFamilyMemberTableViewController ()

@property (strong, nonatomic) NSMutableDictionary *pendingFieldDictionary;
@property (strong, nonatomic) NSArray* userPropertyArray;
@property (strong, nonatomic) NSArray* userPropertyArrayDisplayText;


@property (weak, nonatomic) IBOutlet UIButton *editPhotoButton;

@end

@implementation CreateFamilyMemberTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userPropertyArray = @[ @"firstName", @"lastName", @"homeTown", @"family" ];
    self.userPropertyArrayDisplayText = @[ @"First Name", @"Last Name", @"Hometown", @"Family" ];
    
    self.pendingFieldDictionary = [NSMutableDictionary dictionary];
    
    [self.editPhotoButton.layer setCornerRadius:self.editPhotoButton.bounds.size.width/2];
    [self.editPhotoButton.layer setBorderWidth:3];
    [self.editPhotoButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.editPhotoButton setClipsToBounds:YES];
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
                                                       withValue:self.pendingFieldDictionary[property]];
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
       // self.user[key] = self.pendingFieldDictionary[key];
    }
//    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//        [hud hide:YES afterDelay:.5];
//    }];
    return YES;
}


- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



//
//- (IBAction)editPhotoButtonPressed:(id)sender {
//    
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
//    {
//        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
//        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
//        imagePickerController.delegate = self;
//        imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
//        imagePickerController.videoMaximumDuration = 15;
//        [imagePickerController setAllowsEditing:YES];
//        
//        self.imagePickerController = imagePickerController;
//        [self.navigationController.tabBarController presentViewController:self.imagePickerController animated:YES completion:nil];
//    }
//    
//}

@end
