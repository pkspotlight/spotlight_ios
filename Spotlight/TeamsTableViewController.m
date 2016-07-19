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


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
   // [self refresh:self.refreshControl];
}

- (void)refresh:(UIRefreshControl*)sender {
    [sender beginRefreshing];
    self.teams = [NSMutableArray array];
    [self.tableView reloadData];
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
            [self sortTeamsArray:self.teams];
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
            [self sortTeamsArray:self.teams];
            [self.tableView reloadData];
            [sender endRefreshing];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [sender endRefreshing];
        }
    }];
}

- (void)sortTeamsArray:(NSMutableArray*)teams {
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
    self.teams = [NSMutableArray arrayWithArray:sortedArray];
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

- (IBAction)unwindDeleteTeam:(UIStoryboardSegue*)sender {
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
                                                    [self refresh:self.refreshControl];
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
