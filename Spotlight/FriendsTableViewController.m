//
//  FriendsTableViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 11/5/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "SpotlightFeedViewController.h"
#import "FriendTableViewCell.h"
#import "ChildTableViewCell.h"
#import "FriendProfileViewController.h"
#import <Parse/Parse.h>
#import "User.h"
#import "Team.h"
#import "Child.h"
#import "BasicHeaderView.h"
#import "SpotlightBoardView.h"
#import "FriendFinderTableViewController.h"
#import "PendingRequestTableViewController.h"
#define SpotlightFriendsBoardingText @"This is where you can find all of your friends or teamsMemberArray and follow thier activity. Click on the '+' in the top right to search for your friends!"
static CGFloat const BasicHeaderHeight = 50;


@interface FriendsTableViewController (){
      long count;
}

@property (strong, nonatomic) NSArray* friends;
@property (strong, nonatomic) NSArray* children;
@property (strong, nonatomic) NSMutableArray *pendingRequestArray;
@property (strong, nonatomic) NSMutableArray* teamsMemberArray;
@property (strong, nonatomic) NSMutableArray* teamsSpectMemberArray;

@property (strong, nonatomic) NSMutableArray* friendsArray;

@end

@implementation FriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    count = 0;
    self.teamsMemberArray = [NSMutableArray new];
    self.teamsSpectMemberArray = [NSMutableArray new];
     self.friendsArray = [NSMutableArray new];
    [self.tableView
     registerNib:[UINib nibWithNibName:@"BasicHeaderView" bundle:nil]
     forHeaderFooterViewReuseIdentifier:@"BasicHeaderView"];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self addSpotlightFriendScreenBoardingPopUp];
    self.pendingRequestArray = [NSMutableArray new];
    [self fetchAllPendingRequest];

    [self loadFriends];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:self.refreshControl];
    [self.refreshControl beginRefreshing];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self fetchRequest];
    if(!self.user){
        [self.navigationController setNavigationBarHidden:NO];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PendingRequest" object:nil];
    });
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshScreen) name:@"Frdfollowunfollow" object:nil];
    [self refresh:self.refreshControl];
}

- (void)loadFriends{
    PFQuery *query = [[User currentUser].friends query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.friendsArray = [self alphabetizeArrayOfUsers:[objects copy]];
    }];
}

- (NSMutableArray*)alphabetizeArrayOfUsers:(NSArray*)users{
    return [NSMutableArray arrayWithArray:[users sortedArrayUsingComparator:^NSComparisonResult(User* a, User* b)  {
        return [a.firstName.lowercaseString compare:b.firstName.lowercaseString];
    }]];
}

- (IBAction)searchButtonPressed:(id)sender {
     UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FriendFinderTableViewController *friendFinderController = [storyboard instantiateViewControllerWithIdentifier:@"SearchFriends"];
    [self.navigationController pushViewController:friendFinderController animated:YES];
}


-(void)fetchRequest {
    PFQuery *spotlightQuery = [PFQuery queryWithClassName:@"TeamRequest"];
    [spotlightQuery whereKey:@"admin" equalTo:[User currentUser]];
    [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if(objects.count > 0) {
            NSMutableArray *array = [NSMutableArray new];
            for(TeamRequest *request in objects){
                if((request.requestState.intValue == reqestStatePending)&&([request.type intValue]==2)) {
                    [array addObject:request];
                }
            }
            count = array.count;
            [self.tableView reloadData];
            //  pendingRequest = [NSString stringWithFormat:@"You have %ld request pendings",array.count];
            if(array.count>0){
                [self makeHeaderView];
                [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%lul",(unsigned long)array.count];
            } else {
                self.tableView.tableHeaderView = nil;
                [[self navigationController] tabBarItem].badgeValue  = nil;
            }
        } else {
            self.tableView.tableHeaderView = nil;
            [[self navigationController] tabBarItem].badgeValue  = nil;
        }
    }];
}

-(void)refreshScreen{
    [self refresh:self.refreshControl];
}

-(void)addSpotlightFriendScreenBoardingPopUp{
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"SpotlightFriendsPopUp"] == FALSE)
    {
        
        SpotlightBoardView *spotlightBoardingView = [[[NSBundle mainBundle] loadNibNamed:@"SpotlightBoardView" owner:self options:nil] objectAtIndex:0];
         spotlightBoardingView.lblSpotLightScreenDetailTextBold.text = @"";
        spotlightBoardingView.lblSpotLightScreenDetail.text = SpotlightFriendsBoardingText;
        CGRect frameRect =spotlightBoardingView.frame;
        frameRect.size.width = [UIScreen mainScreen].bounds.size.width;
        frameRect.size.height = [UIScreen mainScreen].bounds.size.height;
        spotlightBoardingView.frame = frameRect;
        [ [[UIApplication sharedApplication].delegate window] addSubview:spotlightBoardingView];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"SpotlightFriendsPopUp"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //Alert code will go here...
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Frdfollowunfollow" object:nil];
}

- (void)refresh:(UIRefreshControl*)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^{
        if (self.team) {
            [self loadTeamMembers:sender];
        } else {
            if (!self.user) {
                self.user = [User currentUser];
            }
            if (!self.justFamily) {
                [self loadFriends:sender];
            }
            [self loadChildren:sender];
        }
    });
}

- (void)loadFriends:(UIRefreshControl*)refresh {
    PFQuery *query = [self.user.friends query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.friends = [objects copy];
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [refresh performSelectorOnMainThread:@selector(endRefreshing) withObject:nil waitUntilDone:NO];
    }];
}

- (void)loadTeamMembers:(UIRefreshControl*)refresh {
    [_teamsMemberArray removeAllObjects];
    [_teamsSpectMemberArray removeAllObjects];
    [self.tableView reloadData];
    PFQuery *query = [PFQuery queryWithClassName:@"Child"];
    [query whereKey:@"teams" equalTo:self.team];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
       
        for(Child *child in objects)
        {
          if([self.team.spectatorsArray containsObject:child.objectId]){
              [_teamsSpectMemberArray addObject:child];
          }
            else
            {
                [_teamsMemberArray addObject:child];
  
            }
            NSArray *newArray=[_teamsMemberArray arrayByAddingObjectsFromArray:_teamsSpectMemberArray];

            [self.delegate getTeamMembers:newArray.mutableCopy];
        }
        
        
        PFQuery *query1 = [PFQuery queryWithClassName:@"_User"];
        [query1 whereKey:@"teams" equalTo:self.team];
        
        [query1 findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            for(User *user in objects){
                if([self.team.spectatorsArray containsObject:user.objectId]){
                    [_teamsSpectMemberArray addObject:user];
                }else{
                    [_teamsMemberArray addObject:user];
                }
            }
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            [refresh performSelectorOnMainThread:@selector(endRefreshing) withObject:nil waitUntilDone:NO];
        }];
    }];
}

- (void)loadChildren:(UIRefreshControl*)refresh {
    PFQuery *query = [self.user.children query];
    NSLog(@"User: %@",self.user.displayName);
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.children = [objects copy];
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [refresh performSelectorOnMainThread:@selector(endRefreshing) withObject:nil waitUntilDone:NO];
    }];
}

- (IBAction)plusButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"CreateFamilyMemberSegue" sender:sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.team) {
        return 2;
    }else if(self.justFamily) {
        return 1;
    }else {
        return 2;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if(self.team) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        label.backgroundColor = [UIColor colorWithRed:40.0/255.0f green:47.0/255.0f blue:61.0/255.0f alpha:1.0];
        label.text = (section == 0) ? @"    Participant" : @"    Fans";
        label.textColor = [UIColor whiteColor];
        
        return label;
    } else {
        BasicHeaderView *cell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"BasicHeaderView"];
        cell.headerTitleLabel.text = (section == 0) ? @"My Family" : @"Friends";
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.team) {
        if(section == 0){
            return  (_teamsMemberArray.count > 0)? 30:0;
        } else {
            return  (_teamsSpectMemberArray.count > 0)? 30:0;
        }
    }else if(self.justFamily) {
        return 0;
    }else {
        return BasicHeaderHeight;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.team) {
        if(section == 0)
        {
        return self.teamsMemberArray.count;
        }
        else
        {
            return self.teamsSpectMemberArray.count;
  
        }
    } else {
        if (section == 0) {
            return self.children.count;
        } else {
            return self.friends.count;
        }
    }
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    
    if (self.team) {
        if(indexPath.section == 0)
        {
        if ([self.teamsMemberArray[indexPath.row] isKindOfClass:[Child class]]){
            cell = (ChildTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ChildTableViewCell"
                                                                        forIndexPath:indexPath];
            [(ChildTableViewCell*)cell setTeam:self.team];
            [(ChildTableViewCell*)cell formatForChild:self.teamsMemberArray [indexPath.row] isSpectator:YES isFollowing:YES];
         
        } else if ([self.teamsMemberArray[indexPath.row] isKindOfClass:[User class]]){
            cell = (FriendTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"FriendTableViewCell"
                                                                         forIndexPath:indexPath];
             [(FriendTableViewCell*)cell setTeam:self.team];
            [(FriendTableViewCell*)cell formatForUser:self.teamsMemberArray[indexPath.row] isSpectator:YES  isFollowing:YES];
            
             [(FriendTableViewCell*)cell followButton].hidden = YES;
                     // [(FriendTableViewCell*)cell userDisplayNameLabel].textColor = [UIColor purpleColor];
        }
        }
        else
        {
            if ([self.teamsSpectMemberArray[indexPath.row] isKindOfClass:[Child class]]){
                cell = (ChildTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ChildTableViewCell"
                                                                            forIndexPath:indexPath];
                [(ChildTableViewCell*)cell setTeam:self.team];
                [(ChildTableViewCell*)cell formatForChild:self.teamsSpectMemberArray [indexPath.row] isSpectator:YES isFollowing:YES];
                
            } else if ([self.teamsSpectMemberArray[indexPath.row] isKindOfClass:[User class]]){
                cell = (FriendTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"FriendTableViewCell"
                                                                             forIndexPath:indexPath];
                [(FriendTableViewCell*)cell setTeam:self.team];
                [(FriendTableViewCell*)cell formatForUser:self.teamsSpectMemberArray[indexPath.row] isSpectator:YES  isFollowing:YES];
                
                [(FriendTableViewCell*)cell followButton].hidden = YES;
                // [(FriendTableViewCell*)cell userDisplayNameLabel].textColor = [UIColor purpleColor];
            }
        }
    } else {
        if (indexPath.section == 0) {
            cell = (ChildTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ChildTableViewCell"
                                                                        forIndexPath:indexPath];
            
            [(ChildTableViewCell*)cell formatForChild:self.children[indexPath.row] isSpectator:NO isFollowing:YES];
        } else {
            cell = (FriendTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"FriendTableViewCell"
                                                                         forIndexPath:indexPath];
            
            [(FriendTableViewCell*)cell formatForUser:self.friends[indexPath.row] isSpectator:NO isFollowing:YES];
           
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"FriendDetailsSegue"]) {
//        id user = (self.team) ? self.teamsMemberArray[[self.tableView indexPathForCell:sender].row] : self.friends[[self.tableView indexPathForCell:sender].row];
//        [(FriendProfileViewController*)[segue destinationViewController] setUser:user];
//    }
//    if ([segue.identifier isEqualToString:@"SearchFriendsSegue"]) {
//    } else
    if ([segue.identifier isEqualToString:@"CreateFamilyMemberSegue"]) {
    }
//    } else if ([segue.identifier isEqualToString:@"ChildDetailsSegue"]) {
//        id user = (self.team) ? self.teamsMemberArray[[self.tableView indexPathForCell:sender].row] : self.children[[self.tableView indexPathForCell:sender].row];
//         [(FriendProfileViewController*)[segue destinationViewController] setChild:user];
//    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    User *user;
    Child *child;
   
    if(self.team){
    
        if(indexPath.section == 0)
        {
        if ([self.teamsMemberArray[indexPath.row] isKindOfClass:[Child class]]){
              child   = self.teamsMemberArray[indexPath.row];
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FriendProfileViewController *friendProfileViewController = [storyboard instantiateViewControllerWithIdentifier:@"FriendsProfile"];
            [friendProfileViewController setChild:child];
            
            [self.navigationController pushViewController:friendProfileViewController animated:YES];
            return;

        }
        else{
              user   = self.teamsMemberArray[indexPath.row];
            
            if(([[self.friendsArray valueForKeyPath:@"objectId"] containsObject:user.objectId]))
            {
                
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                FriendProfileViewController *friendProfileViewController = [storyboard instantiateViewControllerWithIdentifier:@"FriendsProfile"];
                [friendProfileViewController setUser:user];
                [self.navigationController pushViewController:friendProfileViewController animated:YES];
                
                
                
                
            }
            else{
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:@"You do not have access to view Profile. Please request to view this friend profile."
                                           delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:NSLocalizedString(@"Send Invite", nil), nil] show];
            }
            
            

        }
    }
        else
        {
            if ([self.teamsSpectMemberArray[indexPath.row] isKindOfClass:[Child class]]){
                child   = self.teamsSpectMemberArray[indexPath.row];
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                FriendProfileViewController *friendProfileViewController = [storyboard instantiateViewControllerWithIdentifier:@"FriendsProfile"];
                [friendProfileViewController setChild:child];
                [self.navigationController pushViewController:friendProfileViewController animated:YES];
                return;
                
            }
            else{
                user   = self.teamsSpectMemberArray[indexPath.row];
                
                if(([[self.friendsArray valueForKeyPath:@"objectId"] containsObject:user.objectId]))
                {
                    
                    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    FriendProfileViewController *friendProfileViewController = [storyboard instantiateViewControllerWithIdentifier:@"FriendsProfile"];
                    [friendProfileViewController setUser:user];
                    [self.navigationController pushViewController:friendProfileViewController animated:YES];
                    
                    
                    
                    
                }
                else{
                    [[[UIAlertView alloc] initWithTitle:@""
                                                message:@"You do not have access to view Profile. Please request to view this friend profile."
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:NSLocalizedString(@"Send Invite", nil), nil] show];
                }
                
                
                
            }
        }
        
          }
    else{
       
        
        if([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[ChildTableViewCell class]])
        {
            child = self.children[indexPath.row];
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FriendProfileViewController *friendProfileViewController = [storyboard instantiateViewControllerWithIdentifier:@"FriendsProfile"];
            [friendProfileViewController setChild:child];
            [self.navigationController pushViewController:friendProfileViewController animated:YES];
            return;
        }
        else
        {
            user = self.friendsArray[indexPath.row];
            if(([[self.friendsArray valueForKeyPath:@"objectId"] containsObject:user.objectId]))
            {
                
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                FriendProfileViewController *friendProfileViewController = [storyboard instantiateViewControllerWithIdentifier:@"FriendsProfile"];
                [friendProfileViewController setUser:user];
                [self.navigationController pushViewController:friendProfileViewController animated:YES];
                
                
                
                
            }
            else{
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:@"You do not have access to view Profile. Please request to view this friend profile."
                                           delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:NSLocalizedString(@"Send Invite", nil), nil] show];
            }
            

        }
       
    }
    
  }


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex ==1){
        [self sendFriendRequest];
    }
    
    
}



-(void)sendFriendRequest{
    
    NSString *timestamp =  [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    
    TeamRequest *teamRequest = [[TeamRequest alloc]init];
    
    if(![self isRequestAllowed:NO withUser:self.user withChild:nil withTeam:nil]){
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:@"A request to follow this team is already sent to admin."
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
    }
    
    else{
        
        [teamRequest saveTeam:nil andAdmin:self.user  followby:[User currentUser] orChild:nil withTimestamp:timestamp isChild:nil isType:@2 completion:^{
            
            [self.tableView reloadData];
            [_pendingRequestArray addObject:teamRequest];
            
        }];
  

}
}

-(void)makeHeaderView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [view addGestureRecognizer:singleFingerTap];
    
    
    //The event handling method
    
    
    
    /* Section header is in 0th index... */
    [label setText:[NSString stringWithFormat:@"You have %ld pending %@",count , (count==1)?@"Request":@"Requests"]];
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    view.backgroundColor = [UIColor redColor];
    label.textColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = view;

}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PendingRequestTableViewController *pendingRequestController = [storyboard instantiateViewControllerWithIdentifier:@"PendingRequest"];
    [self.navigationController pushViewController:pendingRequestController animated:YES];
    
    //Do stuff here...
}

-(void)fetchAllPendingRequest{
        
        PFQuery *spotlightQuery = [PFQuery queryWithClassName:@"TeamRequest"];
        [spotlightQuery whereKey:@"user" equalTo:[User currentUser]];
        
        [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(objects.count > 0)
            {
                // NSMutableArray *array = [NSMutableArray new];
                for(TeamRequest *request in objects)
                {
                    if((request.requestState.intValue == reqestStatePending) && [request.type intValue]==2)
                    {
                        
                        [_pendingRequestArray addObject:request];
                        
                    }
                    
                }
                
                
            }
            else{
                //[[[self  tabBar]items] objectAtIndex:2].badgeValue  = nil;
            }
            
            
        }];
        
    }
    
    
-(BOOL)isRequestAllowed:(BOOL)isChild withUser:(User*)user withChild:(Child*)child withTeam:(Team*)team {
        
        
        for(TeamRequest *request in _pendingRequestArray){
            
            if(([request.admin.objectId isEqualToString:self.user.objectId])){
                return NO;
            }
            
        }
        
        return YES;
        
        
        
    }
    
   

- (IBAction)unwindAddFriends:(UIStoryboardSegue*)sender {
   // [self.refreshControl beginRefreshing];
   // [self refresh:self.refreshControl];
}

- (IBAction)unwindCancelAddFamilyMember:(UIStoryboardSegue*)sender {
    
}

- (IBAction)unwindSaveFamilyMember:(UIStoryboardSegue*)sender {
   // [self.refreshControl beginRefreshing];
  //  [self refresh:self.refreshControl];
}

@end
