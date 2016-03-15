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

@property (strong, nonatomic) NSMutableArray *teams;

@end

@implementation TeamsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"BasicHeaderView" bundle:nil]
forHeaderFooterViewReuseIdentifier:@"BasicHeaderView"];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl  addTarget:self
                             action:@selector(refresh:)
                   forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:self.refreshControl];
    self.teams = [NSMutableArray array];
    if (!self.child && !self.user) {
        self.user = [User currentUser];
    }
    [self refresh:self.refreshControl];
}

- (void)refresh:(UIRefreshControl*)sender {
    [sender beginRefreshing];
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
            [self.teams addObjectsFromArray:[objects copy]];
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
            [self.teams addObjectsFromArray:[objects copy]];
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

- (void)reloadTable {
    [self refresh:nil];
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
    [self refresh:self.refreshControl];
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
