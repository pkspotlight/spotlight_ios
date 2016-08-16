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
#import "Parse.h"
#import "User.h"
#import "Team.h"
#import "Child.h"
#import "BasicHeaderView.h"

static CGFloat const BasicHeaderHeight = 50;


@interface FriendsTableViewController ()

@property (strong, nonatomic) NSArray* friends;
@property (strong, nonatomic) NSArray* children;
@property (strong, nonatomic) NSArray* teammates;

@end

@implementation FriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView
     registerNib:[UINib nibWithNibName:@"BasicHeaderView" bundle:nil]
     forHeaderFooterViewReuseIdentifier:@"BasicHeaderView"];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:self.refreshControl];
    [self.refreshControl beginRefreshing];
    //[self refresh:self.refreshControl];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshScreen) name:@"FriendFollowUnfollow" object:nil];
    [self refresh:self.refreshControl];
}

-(void)refreshScreen {
    [self refresh:self.refreshControl];
}


-(void)viewWillDisappear:(BOOL)animated {
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
    PFQuery *query = [PFQuery queryWithClassName:@"Child"];
    [query whereKey:@"teams" equalTo:self.team];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.teammates = [objects copy];
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [refresh performSelectorOnMainThread:@selector(endRefreshing) withObject:nil waitUntilDone:NO];
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
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Search/Add Spotlighters"
                                                                    message:@""
                                                             preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Search/Add Spotlighters"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self performSegueWithIdentifier:@"SearchFriendsSegue"
                                                                          sender:sender];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Add Family Members"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self performSegueWithIdentifier:@"CreateFamilyMemberSegue"
                                                                          sender:sender];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                            }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.team || self.justFamily) {
        return 1;
    } else if (self.children.count == 0){
        return 1;
    } else {
        return 2;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BasicHeaderView *cell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"BasicHeaderView"];
    cell.headerTitleLabel.text = (section == 0 && self.children.count != 0) ? @"My Family" : @"Friends";
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.team || self.justFamily) {
        return 0;
    } else {
        return BasicHeaderHeight;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.team) {
        return self.teammates.count;
    } else {
        if (section == 0 || self.children.count == 0) {
            return self.children.count;
        } else {
            return self.friends.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    
    if (self.team) {
        if ([self.teammates[indexPath.row] isKindOfClass:[Child class]]){
            cell = (ChildTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ChildTableViewCell"
                                                                        forIndexPath:indexPath];
            
            [(ChildTableViewCell*)cell formatForChild:self.teammates[indexPath.row] isFollowing:YES];
        } else if ([self.teammates[indexPath.row] isKindOfClass:[User class]]){
            cell = (FriendTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"FriendTableViewCell"
                                                                         forIndexPath:indexPath];
            
            [(FriendTableViewCell*)cell formatForUser:self.teammates[indexPath.row] isFollowing:YES];
        }
    } else {
        if (indexPath.section == 0 || self.children.count == 0) {
            cell = (ChildTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ChildTableViewCell"
                                                                        forIndexPath:indexPath];
            
            [(ChildTableViewCell*)cell formatForChild:self.children[indexPath.row] isFollowing:YES];
        } else {
            cell = (FriendTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"FriendTableViewCell"
                                                                         forIndexPath:indexPath];
            
            [(FriendTableViewCell*)cell formatForUser:self.friends[indexPath.row] isFollowing:YES];
        }
    }
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FriendDetailsSegue"]) {
        id user = (self.team) ? self.teammates[[self.tableView indexPathForCell:sender].row] : self.friends[[self.tableView indexPathForCell:sender].row];
        [(FriendProfileViewController*)[segue destinationViewController] setUser:user];
    } else if ([segue.identifier isEqualToString:@"SearchFriendsSegue"]) {
    } else if ([segue.identifier isEqualToString:@"CreateFamilyMemberSegue"]) {
    } else if ([segue.identifier isEqualToString:@"ChildDetailsSegue"]) {
        id user = (self.team) ? self.teammates[[self.tableView indexPathForCell:sender].row] : self.children[[self.tableView indexPathForCell:sender].row];
         [(FriendProfileViewController*)[segue destinationViewController] setChild:user];
    }
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
