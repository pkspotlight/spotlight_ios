//
//  TeamSelectTableViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 11/20/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "TeamSelectTableViewController.h"
#import "CreateSpotlightTableViewController.h"
#import "TeamTableViewCell.h"
#import "Team.h"

#import "BasicHeaderView.h"
#import "Parse.h"
#import "User.h"

static CGFloat const BasicHeaderHeight = 50;


@interface TeamSelectTableViewController ()

@property (strong, nonatomic) NSArray *myTeams;

@end


@implementation TeamSelectTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"BasicHeaderView" bundle:nil]
forHeaderFooterViewReuseIdentifier:@"BasicHeaderView"];
    self.myTeams = [NSArray array];
    [self loadMyTeams];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadMyTeams {
    PFQuery *query = [[[User currentUser] teams] query];
    [query includeKey:@"teamLogoMedia"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved my %lu Teams.", (unsigned long)objects.count);
            self.myTeams = objects;
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.myTeams.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TeamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeamTableViewCell" forIndexPath:indexPath];
    Team* team = self.myTeams[indexPath.row];
    [cell formatForTeam:team isFollowing:(indexPath.section == 0)];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BasicHeaderView *cell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"BasicHeaderView"];
    cell.headerTitleLabel.text = @"Select the team for this Spotlight";
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return BasicHeaderHeight;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     Team* team = self.myTeams[indexPath.row];
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CreateSpotlightTableViewController *createSpotlight = [storyboard instantiateViewControllerWithIdentifier:@"CreateSpotlightTableViewController"];
   
    createSpotlight.team = team;
    [self.navigationController pushViewController:createSpotlight animated:YES];

}
#pragma mark - Navigation

- (IBAction)cancelButtonPressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"CreateSpotlightSeque"]) {
//        Team* team = self.myTeams[[[self.tableView indexPathForCell:sender] row]];
//        CreateSpotlightTableViewController* vc = (CreateSpotlightTableViewController*)[segue destinationViewController];
//        [vc setTeam:team];
//    }
//    // Pass the selected object to the new view controller.
//}

@end
