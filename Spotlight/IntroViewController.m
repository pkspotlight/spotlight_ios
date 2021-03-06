//
//  IntroViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 9/10/15.
//  Copyright (c) 2015 Spotlight. All rights reserved.
//

#import "IntroViewController.h"
#import "MainTabBarController.h"
#import "SignUpTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SDWebImageManager.h"
#import "ProfilePictureMedia.h"
#import "User.h"

@interface IntroViewController ()

@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *loginWithFBBtn;

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

#pragma mark - Navigation

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//    if([segue.identifier isEqualToString:@"LoginSegueIdentifier"]) {
//        [(SignUpTableViewController*)[segue destinationViewController] setIsLoginScreen:YES];
//    } else {
//        [(SignUpTableViewController*)[segue destinationViewController] setIsLoginScreen:NO];
//    }
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}

- (IBAction)logIn:(UIButton *)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignUpTableViewController *signup = [storyboard instantiateViewControllerWithIdentifier:@"SignUP"];
    signup.isLoginScreen = YES;
    [self.navigationController pushViewController:signup animated:YES];
}

- (IBAction)SignUpClicked:(UIButton *)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignUpTableViewController *signup = [storyboard instantiateViewControllerWithIdentifier:@"SignUP"];
    signup.isLoginScreen = NO;
    [self.navigationController pushViewController:signup animated:YES];
}
- (IBAction)termOfUserPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.myspotlight.me/terms-of-use/"]];
}

- (IBAction)privacyPolicyPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.myspotlight.me/privacy-policy/"]];
}


- (IBAction)logInWithFacebookBtnClicked:(UIButton *)sender {
    
    NSArray *permissionArray = @[@"public_profile",@"email",@"user_birthday"];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionArray block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (user) {
            NSLog(@"sweet");
            //if(user.isNew)
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

-(void)fetchFbData
{
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"id,first_name,last_name,picture.width(500).height(500),email,birthday"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 User *user = [User currentUser];
                 //  if (user.isNew)
                 {
                     user.email = result[@"email"];
                     user.firstName = result[@"first_name"];
                     user.lastName = result[@"last_name"];
                     user.username = [NSString stringWithFormat:@"%@.%@", user.lastName, user.firstName];
                     NSDateFormatter *sdateFormatter = [[NSDateFormatter alloc] init];
                     sdateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                     [sdateFormatter setDateFormat:@"MM/dd/yyyy"];
                     user.birthdate = [sdateFormatter dateFromString:result[@"birthday"]];
                     SDWebImageManager *manager = [SDWebImageManager sharedManager];
                     [manager downloadImageWithURL:[NSURL URLWithString:result[@"picture"][@"data"][@"url"]]
                                           options:0
                                          progress:^(NSInteger receivedSize, NSInteger expectedSize)
                      {
                          
                      }
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished,NSURL *imageURL) {
                                             if (image) {
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


@end
