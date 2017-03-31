//
//  AppDelegate.m
//  Spotlight
//
//  Created by Peter Kamm on 8/28/15.
//  Copyright (c) 2015 Spotlight. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Parse/Parse.h>
#import "Spotlight.h"
#import "SpotlightMedia.h"
#import "User.h"
#import "TeamRequest.h"

#import "Organization.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _acceptedTeamIDs = [[NSMutableArray alloc] init];
    [Fabric with:@[[Crashlytics class]]];
    [Spotlight registerSubclass];
    [SpotlightMedia registerSubclass];
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"nuNuhBJQp4cYfeUnWlNFo27QUCKeAgWBX5D74r4F";
        configuration.clientKey = @"vMH2XfoFKQAy8vbOYzgXZtJrRJ8LjCD5933k3kPF";
        configuration.server = @"http://parse-spotlight.us-east-1.elasticbeanstalk.com/parse";
    }]];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];

    if (![PFUser currentUser]){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        UIViewController *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"IntroNavigationController"];
        [self.window setRootViewController:controller];
    }
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
       // [[NSNotificationCenter defaultCenter] postNotificationName:@"PendingRequest" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAlertForAcceptedRequest" object:nil];
    });
//    [self createOrg];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    PFUser *user = [PFUser currentUser];
    if (user) {
        [currentInstallation setObject:user forKey: @"owner"];
        [currentInstallation saveInBackground];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //[PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
 
   
   
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAlertForAcceptedRequest" object:nil];
    });
   
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [FBSDKAppEvents activateApp];
   
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)createOrg{
    Organization* org = [[Organization alloc] init];
    TeamLogoMedia *orgLogo = [[TeamLogoMedia alloc] initWithImage:[UIImage imageNamed:@"Big_Little_Skills_Academy.jpg"]];
    [orgLogo setTitle:@"BigSmallLogo"];
    [org setOrgName:@"Big & Small"];
    [org setOrgLogo:orgLogo];
    //    [org.orgOwners addObject:nil];
    [org saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error || !succeeded) {
            NSLog(@"SHIT DONE FUCKED");
        } else {
            NSLog(@"It's in");
        }
    }];
}

@end
