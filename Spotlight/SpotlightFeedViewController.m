//
//  SpotlightFeedViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 9/7/15.
//  Copyright (c) 2015 Spotlight. All rights reserved.
//

#import "SpotlightFeedViewController.h"
#import "Spotlight.h"
#import "SpotlightTableViewCell.h"
#import "SpotlightCollectionViewController.h"
#import "SpotlightMedia.h"
#import "User.h"
#import "MainTabBarController.h"
#import "SpotlightDataSource.h"
#import "TeamSelectTableViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "SpotlightBoardView.h"
#define SpotlightFeedBoardingText @"A Spotlight is group of shared media from an event.For example,you could create a Spotlight for basketball game and share all the pictures and videos you took.Click on our Spotlight to check it out!"
@interface SpotlightFeedViewController ()
{
    UIRefreshControl* refresh;
}
@end

@implementation SpotlightFeedViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshScreen) name:@"SpotLightRefersh" object:nil];
    [self addSpotlightScreenBoardingPopUp];
    refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
   
    if (!self.dataSource) self.dataSource = [[SpotlightDataSource alloc] init];
    self.dataSource.delegate = self;
    [self.tableView setDataSource:self.dataSource];
    [self.tableView addSubview:refresh];
    [self refresh:refresh];
    [refresh beginRefreshing];
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, 320, 70);
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spotlightWriting"]];
    imgView.frame = CGRectMake(58, 0, 240, 70);
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    [headerView addSubview:imgView];
    
    self.navigationItem.titleView = headerView;
}


-(void)addSpotlightScreenBoardingPopUp{
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"SpotlightPopUp"] == FALSE)
    {
    
        SpotlightBoardView *spotlightBoardingView = [[[NSBundle mainBundle] loadNibNamed:@"SpotlightBoardView" owner:self options:nil] objectAtIndex:0];
        spotlightBoardingView.lblSpotLightScreenDetailTextBold.text = @"Welcome to Spotlight";

        spotlightBoardingView.lblSpotLightScreenDetail.text = SpotlightFeedBoardingText;
    CGRect frameRect =spotlightBoardingView.frame;
        frameRect.size.width = [UIScreen mainScreen].bounds.size.width;
        frameRect.size.height = [UIScreen mainScreen].bounds.size.height;
    spotlightBoardingView.frame = frameRect;
    
        [ [[UIApplication sharedApplication].delegate window] addSubview:spotlightBoardingView];
    spotlightBoardingView.translatesAutoresizingMaskIntoConstraints = true;
    [spotlightBoardingView.superview layoutIfNeeded];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"SpotlightPopUp"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //Alert code will go here...
    }
    
}

- (void)refresh:(id)sender {

//    if([self.navigationController.viewControllers.lastObject isKindOfClass:[TeamSelectTableViewController class]]){
//        
//        MainTabBarController *tabbar = (MainTabBarController*)[[UIApplication sharedApplication].delegate.window rootViewController];
//        
//       UINavigationController *navController = (UINavigationController *)[tabbar.viewControllers objectAtIndex:0] ;
//          SpotlightFeedViewController *spotlight = (SpotlightFeedViewController*)[navController.viewControllers firstObject];
//        
//        if(spotlight!=nil){
//            [spotlight.dataSource loadSpotlights:^{
//                [spotlight.tableView reloadData];
//                if(sender)
//                {
//                    if([sender isKindOfClass:[MBProgressHUD class]])
//                    {
//                        MBProgressHUD *hud = (MBProgressHUD *)sender;
//                        [hud hide:YES];
//                    }
//                    else
//                        [sender endRefreshing];
//                }
//            }];
//
//        }
//    }
    
    
    [self.dataSource loadSpotlights:^{
        [self.tableView reloadData];
        if(sender)
        {
        if([sender isKindOfClass:[MBProgressHUD class]])
        {
            MBProgressHUD *hud = (MBProgressHUD *)sender;
            [hud hide:YES];
        }
        else
        [sender endRefreshing];
        }
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PendingRequest" object:nil];
    });
    
   
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SpotLightRefersh" object:nil];

    
}

-(void)refreshScreen
{
    //[self.tableView setContentOffset:CGPointMake(0, -refresh.frame.size.height) animated:YES];

   [self refresh:refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)unwindCreation:(UIStoryboardSegue*)sender {
    [self.dataSource loadSpotlights:^{
        [self.tableView reloadData];
    }];
}

-(void)spotlightDeleted:(MBProgressHUD *)hud
{
    [self refresh:hud];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"SpotlightSegue"]) {
        [(SpotlightCollectionViewController*)[segue destinationViewController] setSpotlight:[(SpotlightTableViewCell*)sender spotlight]];
    }
}


@end
