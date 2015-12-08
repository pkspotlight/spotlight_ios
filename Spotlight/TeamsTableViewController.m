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
#import "Parse.h"
#import "User.h"

static CGFloat const BasicHeaderHeight = 50;

@interface TeamsTableViewController ()

@property (strong, nonatomic) NSArray *allTeams;
@property (strong, nonatomic) NSArray *myTeams;

@end

@implementation TeamsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"BasicHeaderView" bundle:nil]
forHeaderFooterViewReuseIdentifier:@"BasicHeaderView"];
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self
                action:@selector(refresh:)
      forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refresh];
    
    self.allTeams = [NSArray array];
    self.myTeams = [NSArray array];
    if (self.user) {
        self.isCurrentUser = NO;
    } else {
        self.user = [User currentUser];
        self.isCurrentUser = YES;
        [self loadTeams:nil];
    }
    [self loadMyTeams:nil];
}

- (void)refresh:(id)sender {
    [self loadMyTeams:(UIRefreshControl*)sender];
    [self loadTeams:(UIRefreshControl*)sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadTeams:(UIRefreshControl*)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Team"];
    [query includeKey:@"teamLogoMedia"];
    [query whereKey:@"teamParticipants" notEqualTo:self.user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved all %lu Teams.", (unsigned long)objects.count);
            self.allTeams = objects;
            [self.tableView reloadData];
            [sender endRefreshing];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [sender endRefreshing];
        }
    }];

}

- (void)loadMyTeams:(UIRefreshControl*)sender  {
    PFQuery *query = [PFQuery queryWithClassName:@"Team"];
    [query includeKey:@"teamLogoMedia"];
    [query whereKey:@"teamParticipants" equalTo:self.user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved my %lu Teams.", (unsigned long)objects.count);
            self.myTeams = objects;
            [self.tableView reloadData];
            [sender endRefreshing];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [sender endRefreshing];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isCurrentUser) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.myTeams.count;
    }else{
        return self.allTeams.count;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TeamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeamTableViewCell" forIndexPath:indexPath];
    Team* team = (indexPath.section == 0) ? self.myTeams[indexPath.row] : self.allTeams[indexPath.row];
    [cell formatForTeam:team isFollowing:(indexPath.section == 0)];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.isCurrentUser) {
        BasicHeaderView *cell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"BasicHeaderView"];
        cell.headerTitleLabel.text = (section == 0) ? @"My Teams" : @"Add Teams";
        return cell;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.isCurrentUser) {
        return BasicHeaderHeight;
    }
    return 0;
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *path = [self.tableView indexPathForCell:sender];

    if ([segue.identifier isEqualToString:@"teamDetailsSegue"]) {
        Team* team = (path.section == 0) ? self.myTeams[path.row] : self.allTeams[path.row];
        [(TeamDetailsViewController*)[segue destinationViewController] setTeam:team];
    }
}


@end
