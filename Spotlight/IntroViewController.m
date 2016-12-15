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
//
//- (IBAction)logInWithFacebookBtnClicked:(UIButton *)sender {
//    
//    NSArray *permissionArray = @[@"public_profile",@"email",@"user_birthday"];
//    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
//    [loginManager logInWithReadPermissions:permissionArray
//                        fromViewController:self
//                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//                                       if(error){
//                                           NSString *errorString = [error userInfo][@"error"];
//                                           if(error!= nil){
//                                               
//                                               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Facebook Login Failed" message:errorString preferredStyle:UIAlertControllerStyleAlert];
//                                               [alert addAction:[UIAlertAction actionWithTitle:@"OK"
//                                                                                         style:UIAlertActionStyleCancel
//                                                                                       handler:nil]];
//                                               [self presentViewController:alert animated:YES completion:nil];
//                                           }
//                                           NSLog(@"shit, %@",errorString);
//                                           
//                                       } else {
//                                           NSLog(@"sweet");
//                                           [self fetchFbData];
//                                           [self loadMainTabBar];
////                                           PFUser *user = [PFUser user];
////                                           user.username = self.pendingInputDict[@"username"];
////                                           user.email = self.pendingInputDict[@"email"];
////                                           user.password = self.pendingInputDict[@"password"];
//                                        
////                                           
////                                           [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
////                                               if (succeeded) {   // Hooray! Let them use the app now.
////                                                   NSLog(@"sweet");
////                                                   [self fetchFbData];
////                                                   [self loadMainTabBar];
////                                               } else {
////                                                   NSString *errorString = [error userInfo][@"error"];
////                                                   UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Nope" message:errorString preferredStyle:UIAlertControllerStyleAlert];
////                                                   [alert addAction:[UIAlertAction actionWithTitle:@"OK"
////                                                                                             style:UIAlertActionStyleCancel
////                                                                                           handler:nil]];
////                                                   [self presentViewController:alert animated:YES completion:nil];
////                                                   NSLog(@"shit, %@",errorString);
////                                               }
////                                           }];
//                                           
//                                           
//                                       }
//                                   }];
//    
//    
////    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionArray block:^(PFUser * _Nullable user, NSError * _Nullable error) {
////        if (user) {
////            NSLog(@"sweet");
////            if(user.isNew)
////                [self fetchFbData];
////            [self loadMainTabBar];
////        } else {
////            NSString *errorString = [error userInfo][@"error"];
////            if(error!= nil){
////                
////                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Facebook Login Failed" message:errorString preferredStyle:UIAlertControllerStyleAlert];
////                [alert addAction:[UIAlertAction actionWithTitle:@"OK"
////                                                          style:UIAlertActionStyleCancel
////                                                        handler:nil]];
////                [self presentViewController:alert animated:YES completion:nil];
////            }
////            NSLog(@"shit, %@",errorString);
////        }
////    }];
//    
//    
////     logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
////        if (!user) {
////            NSLog(@"Uh oh. The user cancelled the Facebook login.");
////        } else if (user.isNew) {
////            NSLog(@"User signed up and logged in through Facebook!");
////        } else {
////            NSLog(@"User logged in through Facebook!");
////        }
////    }];
//    
//}
//
//-(void)fetchFbData {
//    if ([FBSDKAccessToken currentAccessToken]) {
//        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"id,first_name,last_name,picture.width(500).height(500),email"}]
//         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//             if (!error) {
//                 User *user = [User currentUser];
//                 user.email = result[@"email"];
//                 user.firstName = result[@"first_name"];
//                 user.lastName = result[@"last_name"];
//                 user.username = @"";
//                 [user saveInBackground];
//
//                 SDWebImageManager *manager = [SDWebImageManager sharedManager];
//                 [manager downloadImageWithURL:[NSURL URLWithString:result[@"picture"][@"data"][@"url"]]
//                                       options:0
//                                      progress:nil
//                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished,NSURL *imageURL){
//                                         if (image){
//                                             user.profilePic = [[ProfilePictureMedia alloc] initWithImage:image];
//                                             [user.profilePic saveInBackground];
//                                             [user saveInBackground];
//                                         }
//                                     }];
//                 NSLog(@"fetched user:%@", result);
//             }
//         }];
//    }
//}

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

-(void)fetchFbData
{
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"id,first_name,last_name,picture.width(500).height(500),email"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 User *user = [User currentUser];
                 //  if (user.isNew)
                 {
                     user.email = result[@"email"];
                     user.firstName = result[@"first_name"];
                     user.lastName = result[@"last_name"];
                     user.username = @"";
                     SDWebImageManager *manager = [SDWebImageManager sharedManager];
                     [manager downloadImageWithURL:[NSURL URLWithString:result[@"picture"][@"data"][@"url"]]
                                           options:0
                                          progress:^(NSInteger receivedSize, NSInteger expectedSize)
                      {
                          
                      }
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished,NSURL *imageURL)
                      {
                          if (image)
                          {
                              // do something with image
                              
                              user.profilePic = [[ProfilePictureMedia alloc] initWithImage:image];
                              
                              [user.profilePic saveInBackground];
                              // PFFile *imageFile = [PFFile fileWithName:@"profilePic" data:imageNSData];
                              //   user[@"profilePic"] = imageFile;
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
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PendingRequest" object:nil];
    });
    
    [[UIApplication sharedApplication].delegate.window setRootViewController:mainTabBarController];
    
}


@end
