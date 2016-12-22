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
#import <Parse/Parse.h>
#import "User.h"

static CGFloat const BasicHeaderHeight = 50;


@interface TeamSelectTableViewController ()

//@property (strong, nonatomic) NSArray *myTeams;

@property (strong, nonatomic) NSMutableDictionary *teamsByYearDictionary;
@property (strong, nonatomic) NSMutableArray *seasons;
@property (strong, nonatomic) NSMutableArray *allTeams;
@end



@implementation TeamSelectTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"BasicHeaderView" bundle:nil]
forHeaderFooterViewReuseIdentifier:@"BasicHeaderView"];
 //   self.allTeams = [NSArray array];
    [self loadMyTeams];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadMyTeams {
//    PFQuery *query = [[[User currentUser] teams] query];
//    [query includeKey:@"teamLogoMedia"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            NSLog(@"Successfully retrieved my %lu Teams.", (unsigned long)objects.count);
//            self.allTeams = objects;
//            [self.tableView reloadData];
//        } else {
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
//}
    PFQuery *query = [[[User currentUser] teams] query];
    [query includeKey:@"teamLogoMedia"];
    [query orderByDescending:@"year"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved my %lu Teams.", (unsigned long)objects.count);
            self.allTeams = [[NSMutableArray alloc] init];
            self.seasons = [[NSMutableArray alloc] init];
            self.teamsByYearDictionary = [[NSMutableDictionary alloc] init];
            [self sortTeamsArray:objects];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

    
- (void)sortTeamsArray:(NSArray*)teams {
    
    // sort all teams by year/season
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
            }  else if ([[a.season lowercaseString] isEqualToString:@"summer"]) {
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
    
    //create season title for each year/season of teams
    for (Team* team in sortedArray) {
        NSString* season = [NSString stringWithFormat:@"%@ - %@", team.year, team.season];
        if (![self.seasons containsObject:season]) {
            [self.seasons addObject:season];
        }
    }
    
    for (NSString* year in self.seasons) {
        
        NSMutableArray* tempSeasonYearTeamsArray = [NSMutableArray array];
        for (Team* team in sortedArray) {
            NSString* season = [NSString stringWithFormat:@"%@ - %@", team.year, team.season];
            if ([season isEqualToString:year] && ![self.teamsByYearDictionary[year] containsObject:team] ) {
                [tempSeasonYearTeamsArray addObject:team];
                [self.allTeams addObject:team];
            }
        }
        
        if (!self.teamsByYearDictionary[year]) {
            [self.teamsByYearDictionary setValue:[self alphabetizeArrayOfTeams:tempSeasonYearTeamsArray] forKey:year];
        }
    }
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.teamsByYearDictionary objectForKey:self.seasons[section]] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TeamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeamTableViewCell" forIndexPath:indexPath];
    Team* team = self.teamsByYearDictionary[self.seasons[indexPath.section]][indexPath.row];
    [cell setDelegate:self];
    [cell formatForTeam:team isFollowing:(([[self.allTeams valueForKeyPath:@"objectId"] containsObject:team.objectId]))];
    cell.followButton.hidden = YES;
    return cell;
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
    
    return view;
}

- (NSArray*)alphabetizeArrayOfTeams:(NSArray*)teams{
    NSArray* sortedTeams = [teams sortedArrayUsingComparator:^NSComparisonResult(Team* a, Team* b)  {
        if ([a.town.lowercaseString compare:b.town.lowercaseString] == NSOrderedSame) {
            return ([a.teamName.lowercaseString compare:b.teamName.lowercaseString]);
        } else {
            return [a.town.lowercaseString compare:b.town.lowercaseString];
        }
    }];
    return sortedTeams;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.seasons.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return (self.seasons.count > 0)?30:0;
}



//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.allTeams.count;
//}
//
//- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    TeamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeamTableViewCell" forIndexPath:indexPath];
//    Team* team = self.allTeams[indexPath.row];
//    [cell formatForTeam:team isFollowing:(indexPath.section == 0)];
//    return cell;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    BasicHeaderView *cell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"BasicHeaderView"];
//    cell.headerTitleLabel.text = @"Select the team for this Spotlight";
//    return cell;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return BasicHeaderHeight;
//}
//
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Team* team = self.teamsByYearDictionary[self.seasons[indexPath.section]][indexPath.row];
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
