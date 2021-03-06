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
#import "Team.h"
#import "MainTabBarController.h"
#import "SpotlightDataSource.h"
#import "TeamSelectTableViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "SpotlightBoardView.h"
#import "UIViewController+AlertAdditions.h"

#define SpotlightFeedBoardingText @"Click \"+\" on the top right to create a Spotlight for a team you created or follow. A Spotlight is a private group of shared media from a game or event. For example, you can create a Spotlight for a basketball game and share all of the photos and videos you captured to a private community of team members. You can then easily create a Spotlight Reel with music that is easily shared via SMS, Email, and social."

@interface SpotlightFeedViewController ()
{
    UIRefreshControl* refresh;
    Spotlight *spotLightCellSelected;
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
    headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 70);
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spotlight_logo_1000px"]];
    imgView.frame = CGRectMake((self.view.frame.size.width-140)/2, 22, 140, 25);
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    
    [headerView addSubview:imgView];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 140;

    self.navigationItem.titleView = headerView;
}


-(void)addSpotlightScreenBoardingPopUp{
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"SpotlightPopUp"] == FALSE)
    {
    
        SpotlightBoardView *spotlightBoardingView = [[[NSBundle mainBundle] loadNibNamed:@"SpotlightBoardView" owner:self options:nil] objectAtIndex:0];
        spotlightBoardingView.lblSpotLightScreenDetailTextBold.text = @"Spotlight Feed";

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
     [self.navigationController setNavigationBarHidden:NO];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SpotlightTableViewCell *cell = (SpotlightTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    spotLightCellSelected = [cell spotlight];
    
    __block BOOL isAllowed = false;
    
    if(self.dataSource.doesCheckForPrivacy){
        
        PFQuery *query = [[[User currentUser] teams] query];
        [query includeKey:@"teamLogoMedia"];
        [query orderByDescending:@"year"];

        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for(Team *team in objects){
                if([team.objectId isEqualToString:spotLightCellSelected.team.objectId]){
                    isAllowed = true;
                    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    SpotlightCollectionViewController *spotLightCollection = [storyboard instantiateViewControllerWithIdentifier:@"SpotLightCollectionView"];
                    [spotLightCollection setSpotlight:spotLightCellSelected];
                    [self.navigationController pushViewController:spotLightCollection animated:YES];
                    
                    break;
                }
            }
            if(!isAllowed){
                UIAlertController* noAccessAlert = [UIAlertController alertControllerWithTitle:nil
                                                                                       message:@"You do not have access to view this Spotlight. Please request to follow this team in order to gain access."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                [noAccessAlert addAction:[UIAlertAction actionWithTitle:@"Send Invite"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                                                                    [self sendRequestToFollowTeam];
                                                                }]];
                [noAccessAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                [self presentViewController:noAccessAlert animated:YES completion:nil];
            }
        }];
    }else{
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SpotlightCollectionViewController *spotLightCollection = [storyboard instantiateViewControllerWithIdentifier:@"SpotLightCollectionView"];
        [spotLightCollection setSpotlight:spotLightCellSelected];
        [self.navigationController pushViewController:spotLightCollection animated:YES];
    }
}

-(void)sendRequestToFollowTeam{
    
    
    PFQuery* moderatorQuery = [spotLightCellSelected.team.moderators query];
    [moderatorQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(objects.count==0){
            [self showOkMessage:@"No admin found for this team"];
        }
        
        else{
            for (User* user in objects) {
                NSString *timestamp =  [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
                
                TeamRequest *teamRequest = [[TeamRequest alloc]init];
                
                [teamRequest saveTeam:spotLightCellSelected.team andAdmin:user  followby:[User currentUser] orChild:nil withTimestamp:timestamp isChild:@0 isType:@1 completion:^{
                    [self.tableView reloadData];
                }];
                break;
                
            }
        }
        
    }];
}
//- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender NS_AVAILABLE_IOS(6_0)
//{
//
//
//}


//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//
//
//
//    if ([[segue identifier] isEqualToString:@"SpotlightSegue"]) {
//        Spotlight *spotLight = [(SpotlightTableViewCell*)sender spotlight];
//
//        __block BOOL isAllowed = false;
//
//
//            PFQuery *query = [[[User currentUser] teams] query];
//            [query includeKey:@"teamLogoMedia"];
//            [query orderByDescending:@"year"];
//
//
//        for(Team *team in [User currentUser].teams)
//        {
//
//        }
//
//
//
//            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//
//                for(Team *team in objects)
//                {
//                    if([team.objectId isEqualToString:spotLight.team.objectId])
//                    {
//                        isAllowed = true;
//
//
//
//                        break;
//                    }
//
//                }
//
//            }];
//            
//        
//            if(!isAllowed)
//            {
//                
//                [[[UIAlertView alloc] initWithTitle:@""
//                                            message:@"You do not have access to view this Spotlight. Please request to follow this team in order to gain access."
//                                           delegate:nil
//                                  cancelButtonTitle:nil
//                                  otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
//                
//                
//            }
//            
//            
//
//        
//        [(SpotlightCollectionViewController*)[segue destinationViewController] setSpotlight:[(SpotlightTableViewCell*)sender spotlight]];
//    }
//}


@end
