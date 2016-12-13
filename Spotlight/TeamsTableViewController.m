//
//  TeamsTableViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "TeamsTableViewController.h"
#import "TeamDetailsViewController.h"
#import "TeamTableViewCell.h"
#import "Team.h"
#import "BasicHeaderView.h"
#import <Parse/Parse.h>
#import "User.h"
#import "Child.h"
#import "TeamRequest.h"
#import "SpotlightBoardView.h"
#import "PendingRequestTableViewController.h"


#define SpotlightTeamBoardingText @"This is where you can find all of the teams that you are interested in. Search for existing team by clicking the '+' or create your own!"

@interface TeamsTableViewController (){
    NSString *pendingRequest;
    long count;
}

@property (strong, nonatomic) NSMutableDictionary *teamsByYearDictionary;
@property (strong, nonatomic) NSMutableArray *seasons;
@property (strong, nonatomic) NSMutableArray *allTeams;

@end

@implementation TeamsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     count = 0;
    pendingRequest = [[NSString alloc]init];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl  addTarget:self
                             action:@selector(refresh:)
                   forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:self.refreshControl];
    [self.refreshControl beginRefreshing];

    [self addSpotlightTeamScreenBoardingPopUp];
    if (!self.child && !self.user) {
        self.user = [User currentUser];
    }
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    count = 0;
     [self fetchRequest];
    [self refresh:self.refreshControl];
}

-(void)addSpotlightTeamScreenBoardingPopUp{
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"SpotlightTeamPopUp"] == FALSE){
        
        SpotlightBoardView *spotlightBoardingView = [[[NSBundle mainBundle] loadNibNamed:@"SpotlightBoardView" owner:self options:nil] objectAtIndex:0];
        spotlightBoardingView.lblSpotLightScreenDetailTextBold.text = @"";
        spotlightBoardingView.lblSpotLightScreenDetail.text =SpotlightTeamBoardingText;
        
        CGRect frameRect =spotlightBoardingView.frame;
        frameRect.size.width = [UIScreen mainScreen].bounds.size.width;
        frameRect.size.height = [UIScreen mainScreen].bounds.size.height;
        spotlightBoardingView.frame = frameRect;
        [ [[UIApplication sharedApplication].delegate window] addSubview:spotlightBoardingView];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"SpotlightTeamPopUp"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //Alert code will go here...
    }
}

-(void)fetchRequest{

    PFQuery *spotlightQuery = [PFQuery queryWithClassName:@"TeamRequest"];
    [spotlightQuery whereKey:@"admin" equalTo:[User currentUser]];
    
    [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if(objects.count > 0){
            NSMutableArray *array = [NSMutableArray new];
            for(TeamRequest *request in objects){
              if((request.requestState.intValue == reqestStatePending)&&(([request.type intValue]==1)||([request.type intValue]==3))){
                 [array addObject:request];
             }
            }
            count = array.count;
            if(array.count>0){
               [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%ld",array.count];
            }else{
                [[self navigationController] tabBarItem].badgeValue  = nil;
            }
            [self setRequestHeader];
        }else{
             [[self navigationController] tabBarItem].badgeValue  = nil;
        }
    }];
}

- (void)refresh:(UIRefreshControl*)sender {
    [sender beginRefreshing];
    self.allTeams = [[NSMutableArray alloc] init];
    self.seasons = [[NSMutableArray alloc] init];
    self.teamsByYearDictionary = [[NSMutableDictionary alloc] init];
    
    if (self.child){
        [self loadChildTeams:self.child sender:sender];
    } else {
        [self loadUserTeams:sender];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadUserTeams:(UIRefreshControl*)sender  {
    PFQuery *query = [[self.user teams] query];
    [query includeKey:@"teamLogoMedia"];
    [query orderByDescending:@"year"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved my %lu Teams.", (unsigned long)objects.count);
         
            [self sortTeamsArray:objects];
            PFQuery *query = [self.user.children query];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                for (Child* child in objects) {
                    [self loadChildTeams:child sender:sender];
                }
                [self.tableView reloadData];
                [sender endRefreshing];
            }];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [sender endRefreshing];
        }
    }];
}

- (void)loadChildTeams:(Child*)child sender:(UIRefreshControl*)sender {
    PFQuery *query = [child.teams query];
    [query includeKey:@"teamLogoMedia"];
    [query orderByDescending:@"year"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved child's %lu Teams.", (unsigned long)objects.count);
            [self sortTeamsArray:objects];
            [self.tableView reloadData];
            [sender endRefreshing];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [sender endRefreshing];
        }
    }];
}

- (void)sortTeamsArray:(NSArray*)teams {
    NSArray *sortedArray = [teams sortedArrayUsingComparator:^NSComparisonResult(Team* a, Team* b) {
        if (a.year == b.year) {
            if ([[a.season lowercaseString] isEqualToString:@"fall"]) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if ([[a.season lowercaseString] isEqualToString:@"winter"]) {
                if ([[b.season lowercaseString] isEqualToString:@"fall"]) {
                    return (NSComparisonResult)NSOrderedAscending;
                }else{
                    return (NSComparisonResult)NSOrderedDescending;
                }
            }  else if ([[a.season lowercaseString] isEqualToString:@"spring"]) {
                if ([[b.season lowercaseString] isEqualToString:@"fall"] || [[b.season lowercaseString] isEqualToString:@"winter"]) {
                    return (NSComparisonResult)NSOrderedDescending;
                }else{
                    return (NSComparisonResult)NSOrderedAscending;
                }
            } else {
                return (NSComparisonResult)NSOrderedDescending;
            }
        } else if (a.year > b.year) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedDescending;
    }];
    
    for (Team* team in sortedArray) {
        NSString* season = [NSString stringWithFormat:@"%@ - %@", team.year, team.season];
        if (![self.seasons containsObject:season]) {
            [self.seasons addObject:season];
        }
    }
    
    for (NSString* year in self.seasons) {
        if (!self.teamsByYearDictionary[year]) {
            [self.teamsByYearDictionary setValue:[NSMutableArray array] forKey:year];
        }
        for (Team* team in sortedArray) {
            NSString* season = [NSString stringWithFormat:@"%@ - %@", team.year, team.season];
            if ([season isEqualToString:year] && ![self.teamsByYearDictionary[year] containsObject:team] ) {
                [self.teamsByYearDictionary[year] addObject:team];
                [self.allTeams addObject:team];
            }
        }
    }
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.seasons.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return (self.seasons.count > 0)?30:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.teamsByYearDictionary objectForKey:self.seasons[section]] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TeamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeamTableViewCell" forIndexPath:indexPath];
    Team* team = self.teamsByYearDictionary[self.seasons[indexPath.section]][indexPath.row];
    [cell setDelegate:self];
    [cell formatForTeam:team isFollowing:(([[self.allTeams valueForKeyPath:@"objectId"] containsObject:team.objectId]))];
    if(self.isFollowingShow){
        cell.followButton.hidden = YES;
    }else{
        cell.followButton.hidden = NO;
    }
    return cell;
}

- (void)setRequestHeader{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [view addGestureRecognizer:singleFingerTap];
    
    
    /* Section header is in 0th index... */
    [label setText:[NSString stringWithFormat:@"You have %ld pending %@",count , (count==1)?@"request":@"requests"]];
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    view.backgroundColor = [UIColor redColor];
    label.textColor = [UIColor whiteColor];
    
    self.tableView.tableHeaderView = view;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, tableView.frame.size.width, 30)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];

    [label setText:self.seasons[section]];
    label.textAlignment = NSTextAlignmentLeft;
    [view addSubview:label];
    view.backgroundColor = [UIColor colorWithRed:40.0/255.0f green:47.0/255.0f blue:61.0/255.0f alpha:1.0];
    label.textColor = [UIColor whiteColor];
    
    //your background color...
    return view;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PendingRequestTableViewController *pendingRequestController = [storyboard instantiateViewControllerWithIdentifier:@"PendingRequest"];
    [self.navigationController pushViewController:pendingRequestController animated:YES];

}

- (IBAction)addTeamButtonPressed:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Search/Add a New Team"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Search Teams"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self performSegueWithIdentifier:@"SearchTeamsSegue"
                                                                          sender:sender];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Add New Team"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self performSegueWithIdentifier:@"CreateTeamSegue"
                                                                          sender:sender];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                            }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Navigation

- (IBAction)unwindAddTeams:(UIStoryboardSegue*)sender {
    //[self refresh:self.refreshControl];
}

- (IBAction)unwindDeleteTeam:(UIStoryboardSegue*)sender {
//[self refresh:self.refreshControl];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if ([segue.identifier isEqualToString:@"teamDetailsSegue"]) {
        Team* team = self.teamsByYearDictionary[self.seasons[indexPath.section]][indexPath.row];
        [(TeamDetailsViewController*)[segue destinationViewController] setTeam:team];
    } else if ([segue.identifier isEqualToString:@"SearchTeamsSegue"]) {
    } else if ([segue.identifier isEqualToString:@"CreateTeamSegue"]) {
    }
}

# pragma  mark - Delegate Methods

// make all this superclass eventually


- (void)followButtonPressed:(TeamTableViewCell*)teamCell completion:(void (^)(void))completion{
    [[[[User currentUser] children] query] findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self showAlertWithChildren:objects team:teamCell.team completion:completion];
    }];
}

- (void)unfollowButtonPressed:(TeamTableViewCell*)teamCell completion:(void (^)(void))completion{
   //check for children eventually
    
   
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Are you sure?"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [[User currentUser] unfollowTeam:teamCell.team completion:^{
                                                   
                                                    [self refresh:self.refreshControl];
                                                }];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"No"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                            }]];
   
    [self presentViewController:alert animated:YES completion:nil];

    
    
    
}

- (void)showAlertWithChildren:(NSArray*)children team:(Team*)team completion:(void (^)(void))completion {
    if (children && [children count] > 0) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Which Child is on this Team?"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"None, I just want to follow it"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [[User currentUser] followTeam:team completion:^{
                                                        
                                                        [self refresh:self.refreshControl];
                                                        if (completion) {
                                                            completion();
                                                        }
                                                    }];
                                                }]];
        for (Child* child in children) {
            [alert addAction:[UIAlertAction actionWithTitle:[child displayName]
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [child followTeam:team completion:^{
                                                            
                                                            [self refresh:self.refreshControl];
                                                            if (completion) {
                                                                completion();
                                                            }
                                                        }];
                                                    }]];
        }
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * _Nonnull action) {

                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [[User currentUser] followTeam:team completion:^{
            [self refresh:self.refreshControl];
            if (completion) {
                completion();
            }
        }];
    }
}


@end
