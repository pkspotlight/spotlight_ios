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

@interface CreateTeamTableViewController ()

@property (strong, nonatomic) NSArray* teamPropertyArray;
@property (strong, nonatomic) NSArray* teamPropertyDisplay;
@property (strong, nonatomic) TeamLogoMedia* teamLogo;
@property (strong, nonatomic) NSMutableDictionary *pendingFieldDictionary;
@property (strong, nonatomic) UIImagePickerController* imagePickerController;
@property (weak, nonatomic) IBOutlet UIButton *addTeamLogoButton;

@end

@implementation CreateTeamTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.teamPropertyArray = @[ @"teamName", @"town", @"sport", @"grade", @"year", @"season", @"coach"];
    self.teamPropertyDisplay = @[ @"Team Name", @"Town", @"Sport", @"Grade", @"Year", @"Season", @"Coach"];
    self.pendingFieldDictionary = [self newPendingFieldDictionary];
    [self.addTeamLogoButton.layer setCornerRadius:self.addTeamLogoButton.bounds.size.width/2];
    [self.addTeamLogoButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.addTeamLogoButton.layer setBorderWidth:3];
    [self.addTeamLogoButton setClipsToBounds:YES];
}

- (NSMutableDictionary *)newPendingFieldDictionary {
    NSMutableDictionary *fieldDict = [NSMutableDictionary dictionary];
    for (NSString* attribute in self.teamPropertyArray) {
        fieldDict[attribute] = @"";
    }
    return fieldDict;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)savePendingChangesToTeam:(NSError **)error {

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Saving Profile..."];
    
    PFObject *team = [PFObject objectWithClassName:@"Team"
                                        dictionary:self.pendingFieldDictionary];
    team[@"teamLogoMedia"] = self.teamLogo;
    User* user = [User currentUser];
    PFRelation *participantRelation = [team relationForKey:@"teamParticipants"];
    [participantRelation addObject:user];
    
    [team saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        if (error) {
            NSLog(@"fuck: %@", [error localizedDescription]);
        }
    }];
    return YES;
}

- (IBAction)saveAccountPressed:(id)sender {
    NSError *error;
    [self.view endEditing:NO];
    if ([self savePendingChangesToTeam:&error]) {
        [self dismissViewControllerAnimated:YES completion:nil];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.teamPropertyArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FieldEntryTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FieldEntryTableViewCell" forIndexPath:indexPath];
    [cell formatForAttributeString:self.teamPropertyArray[indexPath.row]
                         displayText:self.teamPropertyDisplay[indexPath.row] withValue:@""];
    [cell setDelegate:self];
    
    return cell;
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
    [self.teamLogo saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"fuck: %@", [error localizedDescription]);
        }
    }];
    PFFile* thumbFile = self.teamLogo.thumbnailImageFile;
    [thumbFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        [self.addTeamLogoButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
    }];
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
