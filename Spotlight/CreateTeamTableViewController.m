//
//  CreateTeamTableViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "CreateTeamTableViewController.h"
#import "Team.h"
#import "User.h"
#import "TeamLogoMedia.h"
#import "SpotlightMedia.h"
#import <MBProgressHUD.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "Child.h"
#import "RecieptAlertView.h"
@interface CreateTeamTableViewController ()

@property (strong, nonatomic) NSArray* teamPropertyArray;
@property (strong, nonatomic) NSArray* teamPropertyDisplay;
@property (strong, nonatomic) TeamLogoMedia* teamLogo;
@property (strong, nonatomic) NSMutableDictionary *pendingFieldDictionary;
@property (strong, nonatomic) UIImagePickerController* imagePickerController;
@property (weak, nonatomic) IBOutlet UIButton *addTeamLogoButton;
@property (weak, nonatomic) IBOutlet UIImageView *teamPictureImageView;
@property (weak, nonatomic) IBOutlet UIImageView *teamPictureImageViewFront;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *photoUploadIndicator;
@property (assign, nonatomic) BOOL isNewTeam;
@property (strong, nonatomic) Child* selfChild;
@property (strong, nonatomic) NSMutableArray* childSelectedarray;

@end

@implementation CreateTeamTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.teamPropertyArray = @[ @"teamName", @"town", @"sport", @"grade", @"year", @"season", @"coach"];
    self.teamPropertyDisplay = @[ @"Team Name", @"Town", @"Sport", @"Grade", @"Year", @"Season", @"Coach"];

    [self.photoUploadIndicator setHidden:YES];
    self.childSelectedarray = [NSMutableArray new];
    _selfChild = [Child new];
    
    _selfChild.firstName = [User currentUser].firstName;
    _selfChild.lastName = [User currentUser].lastName;
    _selfChild.hometown = @"";
    _selfChild.profilePic = [User currentUser].profilePic;
    
    if(self.isEdit){
        self.navigationItem.title = @"Edit Team";

    }
    
    if (!self.team) {
        self.team = [Team new];
        self.pendingFieldDictionary = [self newPendingFieldDictionary];
        self.isNewTeam = YES;
    } else {
        self.pendingFieldDictionary = [self populateExistingTeamAttributes:self.team];
        self.isNewTeam = NO;
    }
}

- (NSMutableDictionary *)newPendingFieldDictionary {
    NSMutableDictionary *fieldDict = [NSMutableDictionary dictionary];
    for (NSString* attribute in self.teamPropertyArray) {
        fieldDict[attribute] = @"";
    }
    return fieldDict;
}

- (NSMutableDictionary *)populateExistingTeamAttributes:(Team*)team {
    NSMutableDictionary *fieldDict = [NSMutableDictionary dictionary];
    for (NSString* attribute in self.teamPropertyArray) {
        if (self.team[attribute]) {
            fieldDict[attribute] = self.team[attribute];
        }
    }
    self.teamLogo = self.team.teamLogoMedia;
    PFFile* thumbFile = self.teamLogo.thumbnailImageFile;
    [thumbFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        self.teamPictureImageView.image = [UIImage imageWithData:data];
        self.teamPictureImageViewFront.image = [UIImage imageWithData:data];

        //[self.addTeamLogoButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
    }];
    return fieldDict;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)hasEnteredRequiredFields{
    if ([self.pendingFieldDictionary[@"teamName"] length] == 0) {
        [self showAlertforMissingField:@"team name"];
        return NO;
    } else if ([self.pendingFieldDictionary[@"town"] length] == 0) {
        [self showAlertforMissingField:@"town"];
        return NO;
    } else if ([self.pendingFieldDictionary[@"sport"] length] == 0) {
        [self showAlertforMissingField:@"sport"];
        return NO;
    } else if ([self.pendingFieldDictionary[@"year"] length] == 0) {
        [self showAlertforMissingField:@"year"];
        return NO;
    } else if ([self.pendingFieldDictionary[@"season"] length] == 0) {
        [self showAlertforMissingField:@"season"];
        return NO;
    }
    return YES;
}

- (void)showAlertforMissingField:(NSString*)fieldText {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Missing Field" message:[NSString stringWithFormat:@"Please enter information for the %@ field.", fieldText] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)savePendingChangesToTeam:(NSError **)error {

    if (![self hasEnteredRequiredFields]) {
        return NO;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Saving Profile..."];
    
    for (NSString* key in [self.pendingFieldDictionary allKeys]) {
        if (self.pendingFieldDictionary[key] && ![self.pendingFieldDictionary[key] isEqualToString:@""] ) {
            self.team[key] = self.pendingFieldDictionary[key];
        }
    }
    if (self.teamLogo) {
        self.team.teamLogoMedia = self.teamLogo;
    }
    [self.team.moderators addObject:[User currentUser]];
    [self.team saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            for(Child *child in self.childSelectedarray){
                [child.teams addObject:self.team];
            }
            User* user = [User currentUser];
            [user.teams addObject:self.team];
            
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            [Child saveAllInBackground:self.childSelectedarray block:^(BOOL succeeded, NSError * _Nullable error) {
                
            }];
        }
        if (error) {
            NSLog(@"fuck: %@", [error localizedDescription]);
        }
    }];
    return YES;
}

- (IBAction)saveAccountPressed:(id)sender {
    
    if (![self hasEnteredRequiredFields]) {
        return;
    }
    
    
    [self.view endEditing:NO];

    [[[[User currentUser] children] query] findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(objects.count>0){
           __block NSError *error;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Do you want to associate your family members" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                if ([self savePendingChangesToTeam:&error]) {
                    //[self dismissViewControllerAnimated:YES completion:nil];
                    [self performSegueWithIdentifier:@"UnwindEditSegue" sender:sender];
                } else {
                    //Show some error
                }
                
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                RecieptAlertView *alert = [[RecieptAlertView alloc] init];
                alert.delegate = self;
                
                [alert createAlertWithRemmitances:objects];
                                
            }]];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self presentViewController:alertController animated:YES completion:nil];
            });
        } else {
            if ([self savePendingChangesToTeam:&error]) {
                [self performSegueWithIdentifier:@"UnwindEditSegue" sender:nil];
            } else {
                //Show some error
            }
        }
    }];
}


-(void)RecieptAlertViewdialogButtonWithChildSelected:(NSMutableArray *)childArray{
    NSError *error;
    [self.view endEditing:NO];
    if(childArray!=nil){
         self.childSelectedarray = childArray;
    }
   
        if ([self savePendingChangesToTeam:&error]) {
            //[self dismissViewControllerAnimated:YES completion:nil];
            [self performSegueWithIdentifier:@"UnwindEditSegue" sender:nil];
        } else {
            //Show some error
        }
    
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
    NSInteger index = [self.teamPropertyArray indexOfObject:attribute];
    NSInteger nextIndex = index + 1;
    if (nextIndex < self.teamPropertyArray.count) {
        return [NSIndexPath indexPathForRow:nextIndex inSection:0];
    }
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.isNewTeam) ? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.teamPropertyArray count];
    } else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        FieldEntryTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FieldEntryTableViewCell" forIndexPath:indexPath];
        [cell formatForAttributeString:self.teamPropertyArray[indexPath.row]
                           displayText:self.teamPropertyDisplay[indexPath.row]
                             withValue:self.pendingFieldDictionary[self.teamPropertyArray[indexPath.row]] isCenter:NO];
        [cell setDelegate:self];
        return cell;
    } else {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DeleteTeamCellId" forIndexPath:indexPath];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [self deleteTeam];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)deleteTeam {
    [self.team deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self performSegueWithIdentifier:@"UnwindDeleteTeam" sender:nil];
    }];
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    if(self.isEdit){
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editPhotoButtonPressed:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.delegate = self;
        imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeImage, nil];
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
        self.teamLogo = [[TeamLogoMedia alloc] initWithVideoPath:videoPath];
        
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [infoDict valueForKey:UIImagePickerControllerOriginalImage];
        self.teamLogo = [[TeamLogoMedia alloc] initWithImage:image];
    }
     [self.photoUploadIndicator setHidden:NO];
    [self.photoUploadIndicator startAnimating];
    [self.teamLogo saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        PFFile* thumbFile = self.teamLogo.thumbnailImageFile;
        [thumbFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            
            self.teamPictureImageView.image = [UIImage imageWithData:data];
            self.teamPictureImageViewFront.image = [UIImage imageWithData:data];

           // [self.addTeamLogoButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
            [self.photoUploadIndicator stopAnimating];
            self.photoUploadIndicator.hidesWhenStopped = YES;

        }];
        if (error) {
            NSLog(@"fuck: %@", [error localizedDescription]);
            [self.photoUploadIndicator stopAnimating];
            self.photoUploadIndicator.hidesWhenStopped = YES;
        }
    }];
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
