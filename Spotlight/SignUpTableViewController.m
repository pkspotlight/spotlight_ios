//
//  SignUpTableViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 9/9/15.
//  Copyright (c) 2015 Spotlight. All rights reserved.
//

#define thirteenYearsInSeconds 409968000

#import "SignUpTableViewController.h"
#import "SpotlightFeedViewController.h"
#import "MainTabBarController.h"
#import "User.h"
#import <Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SDWebImageManager.h"
#import "ProfilePictureMedia.h"



@interface SignUpTableViewController ()

@property (strong, nonatomic) NSMutableDictionary *pendingInputDict;
@property (strong, nonatomic) NSArray* userPropertyArray;
@property (strong, nonatomic) NSArray* userPropertyDisplayArray;
@property (weak, nonatomic) IBOutlet UILabel *lblSignUp;
@property (weak, nonatomic) IBOutlet UIButton *btnCreateAccount;

@end

@implementation SignUpTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isLoginScreen) {
        self.userPropertyArray = @[ @"username", @"password"];
        self.userPropertyDisplayArray = @[ @"Username", @"Password"];
        self.lblSignUp.text = @"Login";
        [self.btnCreateAccount setTitle:@"Login" forState:UIControlStateNormal];
        [self.btnCreateAccount addTarget:self action:@selector(LogInButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.userPropertyArray = @[ @"email", @"password", @"username", @"firstName", @"lastName", @"birthdate"];
        self.userPropertyDisplayArray = @[ @"Email Address", @"Password", @"Username", @"First Name", @"Last Name", @"Birthdate"];
        self.lblSignUp.text = @"Create An Account";
        [self.btnCreateAccount setTitle:@"Create An Account" forState:UIControlStateNormal];
        [self.btnCreateAccount addTarget:self action:@selector(createAccountButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.pendingInputDict = [[NSMutableDictionary alloc] init];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    backgroundImageView.image = [UIImage imageNamed:@"BackgroundBasketballImage"];
    self.tableView.backgroundView = backgroundImageView;
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.userPropertyArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell;
    NSString* attribute = self.userPropertyArray[indexPath.row];
    NSString* inputtedValue = (self.pendingInputDict[attribute]) ? self.pendingInputDict[attribute] : @"";
    
    if ([attribute isEqualToString:@"birthdate"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DateFieldTableViewCell" forIndexPath:indexPath];
        [(DateFieldTableViewCell*)cell setDelegate:self];
        [(DateFieldTableViewCell*)cell formatWithDateValue:nil isCenter:YES];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FieldEntryTableViewCell" forIndexPath:indexPath];
        [(FieldEntryTableViewCell*)cell formatForAttributeString:self.userPropertyArray[indexPath.row]
                                                     displayText:self.userPropertyDisplayArray[indexPath.row]
                                                       withValue:inputtedValue isCenter:YES];
        [(FieldEntryTableViewCell*)cell setDelegate:self];
        if ([attribute isEqualToString:@"email"]) {
            [(FieldEntryTableViewCell*)cell setKeyboardType:UIKeyboardTypeEmailAddress];
        }
        if ([attribute isEqualToString:@"password"]) {
            [(FieldEntryTableViewCell*)cell setIsSecure:YES];
        }
        if ([attribute isEqualToString:@"lastName"] || [attribute isEqualToString:@"firstName"]) {
            [(FieldEntryTableViewCell*)cell setAutoCapitalizationType:UITextAutocapitalizationTypeWords];
        }
    }
    return cell;
}

- (void)loadMainTabBar {
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainTabBarController *mainTabBarController = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
    
    if([User currentUser].isNew){
       [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SpotlightPopUp"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SpotlightFriendsPopUp"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SpotlightTeamPopUp"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        mainTabBarController.selectedIndex = 2;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PendingRequest" object:nil];
    });

    [[UIApplication sharedApplication].delegate.window setRootViewController:mainTabBarController];
    
}

- (IBAction)createAccountButtonPressed:(id)sender {
    
    [self.view endEditing:YES];
    
    if (![self isOlderThanThirteen]) {
        UIAlertController* alert = [UIAlertController
                                    alertControllerWithTitle:@"Invalid Date of Birth"
                                    message:@"Please validate that you are over 13 years of age.  If you are under 13, please have your parents sign up!"
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }else if (self.pendingInputDict[@"email"] &&
        [self.pendingInputDict[@"email"] length] > 4 &&
        self.pendingInputDict[@"password"] &&
        [self.pendingInputDict[@"password"] length] > 4 &&
        self.pendingInputDict[@"username"] &&
        [self.pendingInputDict[@"username"] length] > 4) {
        
        User *user = [User user];
        user.username = self.pendingInputDict[@"username"];
        user.email = self.pendingInputDict[@"email"];
        user.password = self.pendingInputDict[@"password"];
        user.birthdate = self.userDOB;
        if (self.pendingInputDict[@"firstName"] ) {
            user.firstName = self.pendingInputDict[@"firstName"];
        }
        if (self.pendingInputDict[@"lastName"] ) {
            user.lastName = self.pendingInputDict[@"lastName"];
        }

        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {   // Hooray! Let them use the app now.
                NSLog(@"sweet");
                [self loadMainTabBar];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Nope" message:errorString preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
                NSLog(@"shit, %@",errorString);
            }
        }];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid Username/Password"
                                                                       message:@"Please make sure that you have entered a valid e-mail address and that your password is at least 4 charaters long" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (BOOL)isOlderThanThirteen {
    NSDate *minDate =  [[NSDate date] initWithTimeInterval:-thirteenYearsInSeconds sinceDate:[NSDate date]];
    return ([minDate compare:self.userDOB] == NSOrderedDescending);
}

- (IBAction)crossButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)LogInButtonPressed:(id)sender {
    
     [self.view endEditing:YES];
    if (self.pendingInputDict[@"username"] &&
        [self.pendingInputDict[@"username"] length] > 4 &&
        self.pendingInputDict[@"password"] &&
        [self.pendingInputDict[@"password"] length] > 4) {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:YES];
                  [hud setLabelText:@"Please Wait..."];
        [User logInWithUsernameInBackground:self.pendingInputDict[@"username"]
                                     password:self.pendingInputDict[@"password"]
                                        block:^(PFUser *user, NSError *error) {
                                            [hud hide:YES];
                                            
                                            if (user) {
                                                NSLog(@"sweet");
                                                
                                                [self loadMainTabBar];
                                            } else {
                                                NSString *errorString = [error userInfo][@"error"];
                                                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Nope" message:errorString preferredStyle:UIAlertControllerStyleAlert];
                                                [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                                                          style:UIAlertActionStyleCancel
                                                                                        handler:nil]];
                                                [self presentViewController:alert animated:YES completion:nil];
                                                NSLog(@"shit, %@",errorString);
                                            }
                                        }];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid Username/Password"
                                                                       message:@"Please make sure that you have entered a valid e-mail address and that your password is at least 4 charaters long" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)logInWithFacebookBtnClicked:(UIButton *)sender {
    
    NSArray *permissionArray = @[@"public_profile",@"email"];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionArray block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (user) {
            NSLog(@"sweet");
            if(user.isNew)
            [self fetchFbData];
            [self loadMainTabBar];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            if(error!= nil){
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Facebook Login Failed" message:errorString preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            }
            NSLog(@"shit, %@",errorString);
        }
    }];
    
    
}

-(void)fetchFbData {
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"id,first_name,last_name,picture.width(500).height(500),email"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                   User *user = [User currentUser];
                 {
                     user.email = result[@"email"];
                     user.firstName = result[@"first_name"];
                     user.lastName = result[@"last_name"];
                     SDWebImageManager *manager = [SDWebImageManager sharedManager];
                     [manager downloadImageWithURL:[NSURL URLWithString:result[@"picture"][@"data"][@"url"]]
                                           options:0
                                          progress:^(NSInteger receivedSize, NSInteger expectedSize){
                                              
                                          }
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished,NSURL *imageURL){
                                             if (image){
                                                 user.profilePic = [[ProfilePictureMedia alloc] initWithImage:image];
                                                 [user.profilePic saveInBackground];
                                                 [user saveInBackground];
                                                 
                                             }
                                         }];
                 }
                 NSLog(@"fetched user:%@", result);
             }
         }];
    }
}


#pragma mark - Delegate Methods

- (void)accountTextFieldCell:(FieldEntryTableViewCell *)cell didChangeToValue:(NSString *)text {
    self.pendingInputDict[cell.attributeString] = text;
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
            if (self.isLoginScreen) {
                [self LogInButtonPressed:nil];
            }else {
                [self createAccountButtonPressed:nil];
            }
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

@end
