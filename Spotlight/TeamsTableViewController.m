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
#import "Child.h"

static CGFloat const BasicHeaderHeight = 50;

@interface TeamsTableViewController ()

@property (strong, nonatomic) NSArray *teams;

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
    
    self.teams = [NSArray array];
    if (!self.child && !self.user) {
        self.user = [User currentUser];
    }
    [self refresh:refresh];
}

- (void)refresh:(id)sender {
    if (self.child){
        [self loadChildTeams:sender];
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
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved my %lu Teams.", (unsigned long)objects.count);
            self.teams = objects;
            [self.tableView reloadData];
            [sender endRefreshing];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [sender endRefreshing];
        }
    }];
}

- (void)loadChildTeams:(UIRefreshControl*)sender {
    PFQuery *query = [self.child.teams query];
    [query includeKey:@"teamLogoMedia"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved my %lu Teams.", (unsigned long)objects.count);
            self.teams = objects;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.teams.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TeamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeamTableViewCell" forIndexPath:indexPath];
    Team* team = self.teams[indexPath.row];
    [cell setDelegate:self];
    [cell formatForTeam:team isFollowing:(indexPath.section == 0)];
    return cell;
}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    if (self.isCurrentUser) {
//        BasicHeaderView *cell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"BasicHeaderView"];
//        cell.headerTitleLabel.text = (section == 0) ? @"My Teams" : @"Add Teams";
//        return cell;
//    } else {
//        return nil;
//    }
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if (self.isCurrentUser) {
//        return BasicHeaderHeight;
//    }
//    return 0;
//}

- (void)reloadTable {
    [self refresh:nil];
}


- (IBAction)addTeamButtonPressed:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Add a New Team"
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
    [self refresh:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *path = [self.tableView indexPathForCell:sender];
    if ([segue.identifier isEqualToString:@"teamDetailsSegue"]) {
        Team* team = self.teams[path.row];
        [(TeamDetailsViewController*)[segue destinationViewController] setTeam:team];
    } else if ([segue.identifier isEqualToString:@"SearchTeamsSegue"]) {
    } else if ([segue.identifier isEqualToString:@"CreateTeamSegue"]) {
    }
}

# pragma  mark - Delegate Methods


@end
