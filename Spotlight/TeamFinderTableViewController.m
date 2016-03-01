//
//  TeamFinderTableViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 2/19/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import "TeamFinderTableViewController.h"
#import "TeamDetailsViewController.h"
#import "TeamTableViewCell.h"
#import "Parse.h"
#import "User.h"
#import "Child.h"
#import "Team.h"

@interface TeamFinderTableViewController()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSArray* searchResults;
@property (strong, nonatomic) UITapGestureRecognizer* hideKeyboardTap;
@end

@implementation TeamFinderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"BasicHeaderView" bundle:nil]
forHeaderFooterViewReuseIdentifier:@"BasicHeaderView"];
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refresh];
    [refresh beginRefreshing];
    self.hideKeyboardTap = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(dismissKeyboard)];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    BasicHeaderView *cell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"BasicHeaderView"];
//    cell.headerTitleLabel.text = (section == 0) ? @"Family" : @"Friends";
//    return cell;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return BasicHeaderHeight;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.searchResults.count == 0) ? 1 : self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    if ([self.searchResults count] == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NoResultsTableViewCell"
                                               forIndexPath:indexPath];
    } else {
        cell = (TeamTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"TeamTableViewCell"
                                                                     forIndexPath:indexPath];
        [(TeamTableViewCell*)cell formatForTeam:self.searchResults[indexPath.row] isFollowing:NO];
        
        [(TeamTableViewCell*)cell setDelegate:self];
    }
    return cell;
}


#pragma mark - SearchBar Delegate Methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    //dismiss keyboard
    [self.searchBar resignFirstResponder];
    
    //Strip the whitespace off the end of the search text
    NSString *searchText = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![searchText isEqualToString:@""]) {
        PFQuery *firstQuery = [Team query];
        PFQuery *secondQuery = [Team query];
        
        [firstQuery whereKey:@"teamName" containsString:searchText];
        [secondQuery whereKey:@"town" containsString:searchText];
        
        PFQuery *query = [PFQuery orQueryWithSubqueries:@[firstQuery,
                                                          secondQuery]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.searchResults = objects;
                if (objects.count > 0) {
                    for (Team *team in objects) {
                        NSLog(@"team: %@ %@ -- %@ %@", team.teamName, team.town);
                    }
                } else {
                    //Show no search results message
                }
                
                //reload the tableView after the user searches
                [self.tableView reloadData];
            } else {
                
            }
        }];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchResults = @[];
    [self.tableView reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        self.searchResults = @[];
        [self.tableView reloadData];
    }
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.view addGestureRecognizer:self.hideKeyboardTap];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.view removeGestureRecognizer:self.hideKeyboardTap];
}

- (void) dismissKeyboard {
    [self.searchBar resignFirstResponder];
}

- (void)followButtonPressed:(TeamTableViewCell*)teamCell {
    
    [[[[User currentUser] children] query] findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self showAlertWithChildren:objects team:teamCell.team];
    }];

}

- (void)showAlertWithChildren:(NSArray*)children team:(Team*)team{
    if (children && [children count] > 0) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Which Child is on this Team?"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"None, I just want to follow it"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [[User currentUser] followTeam:team completion:^{
                                                        
                                                    }];
                                                    
                                                    
//                                                    [self performSegueWithIdentifier:@"SearchTeamsSegue"
//                                                                              sender:nil];
                                                }]];
        for (Child* child in children) {
            [alert addAction:[UIAlertAction actionWithTitle:[child displayName]
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [child followTeam:team completion:^{
                                                            
                                                        }];
//                                                        
//                                                        
//                                                        [self performSegueWithIdentifier:@"CreateTeamSegue"
//                                                                                  sender:nil];
                                                    }]];
        }
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [[User currentUser] followTeam:team completion:^{
            
        }];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//    [(FriendProfileViewController*)[segue destinationViewController] setUser:self.searchResults[[self.tableView indexPathForCell:sender].row]];
//    
}

@end
