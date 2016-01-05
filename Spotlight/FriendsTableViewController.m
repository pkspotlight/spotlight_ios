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
#import "FriendProfileViewController.h"
#import "Parse.h"
#import "User.h"
#import "Team.h"

@interface FriendsTableViewController ()

@property (strong, nonatomic) NSArray* friends;
@property (strong, nonatomic) NSArray* searchResults;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (assign, nonatomic) BOOL isShowingSearchResults;
@property (strong, nonatomic) UITapGestureRecognizer* hideKeyboardTap;

@end

@implementation FriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isShowingSearchResults = NO;
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refresh];
    [refresh beginRefreshing];
    [self refresh:refresh];
    self.hideKeyboardTap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
}

- (void)refresh:(UIRefreshControl*)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^{
        if (self.team) {
            [self loadTeamMembers:sender];
        } else {
            if (!self.user) {
                self.user = [User currentUser];
            }
            [self loadFriends:sender];
        }
    });
}

- (void)loadFriends:(UIRefreshControl*)refresh {
    PFQuery *query = [(PFRelation*)[self.user objectForKey:@"friends"] query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.friends = objects;
        [self.tableView reloadData];
        [refresh endRefreshing];
    }];
}

- (void)loadTeamMembers:(UIRefreshControl*)refresh {
    PFQuery *query = [(PFRelation*)[self.team objectForKey:@"teamParticipants"] query];
    self.friends = [query findObjects];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
        [refresh endRefreshing];
    }];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

//- (IBAction)addFriendButtonPressed:(id)sender {
//    UIAlertController* alert = [UIAlertController
//                                alertControllerWithTitle:@"Enter email of friend"
//                                message:nil
//                                preferredStyle:UIAlertControllerStyleAlert];
//    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        [textField setKeyboardType:UIKeyboardTypeEmailAddress];
//    }];
//    [alert addAction:[UIAlertAction
//                      actionWithTitle:@"Add Friend"
//                      style:UIAlertActionStyleDefault
//                      handler:^(UIAlertAction * _Nonnull action) {
//                          PFQuery *query = [User query];
//                          [query whereKey:@"username" equalTo:alert.textFields[0].text];
//                          [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//                              if (object) {
//                                  PFRelation *participantRelation = [self.user relationForKey:@"friends"];
//                                  [participantRelation addObject:object];
//                                  [self.user save];
//                                  [self loadFriends:nil];
//                              }else {
//                                  UIAlertController* noUserAlert = [UIAlertController
//                                                                    alertControllerWithTitle:@"User does not exist"
//                                                                    message:nil
//                                                                    preferredStyle:UIAlertControllerStyleAlert];
//                                  [noUserAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
//                                  [self presentViewController:noUserAlert animated:YES completion:nil];
//                                  
//                              }
//                              
//                          }];
//                          
//                      }]];
//    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
//    [self presentViewController:alert animated:YES completion:nil];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isShowingSearchResults) {
        return (self.searchResults.count == 0) ? 1 : self.searchResults.count;
    } else {
        return self.friends.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    if ([self.searchResults count] == 0 && self.isShowingSearchResults) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NoResultsTableViewCell"
                                               forIndexPath:indexPath];
    } else {
        cell = (FriendTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"FriendTableViewCell"
                                                                     forIndexPath:indexPath];
        if (self.isShowingSearchResults) {
            [(FriendTableViewCell*)cell formatForUser:self.searchResults[indexPath.row] isFollowing:NO];
        } else {
            [(FriendTableViewCell*)cell formatForUser:self.friends[indexPath.row] isFollowing:YES];
        }
    }
    return cell;
}

- (void) dismissKeyboard {
    [self.searchBar resignFirstResponder];
}


#pragma mark - SearchBar Delegate Methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    //dismiss keyboard
    [self.searchBar resignFirstResponder];
    
    //Strip the whitespace off the end of the search text
    NSString *searchText = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![searchText isEqualToString:@""]) {
        self.isShowingSearchResults = YES;
        PFQuery *firstQuery = [User query];
        PFQuery *secondQuery = [User query];
        PFQuery *thirdQuery = [User query];

        PFQuery *fourthQuery = [User query];
        [firstQuery whereKey:@"firstName" containsString:searchText];
        [secondQuery whereKey:@"lastName" containsString:searchText];
      //  [thirdQuery whereKey:@"email" containsString:[searchText lowercaseString]];
      //  [fourthQuery whereKey:@"username" containsString:searchText];
        
        PFQuery *query = [PFQuery orQueryWithSubqueries:@[firstQuery,
                                                          secondQuery]];
//                                                          thirdQuery,
//                                                          fourthQuery]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.searchResults = objects;
                if (objects.count > 0) {
                    for (User *user in objects) {
                        NSLog(@"user: %@ %@ -- %@ %@", user.firstName, user.lastName, user.email, user.username);
                    }
                } else {
                    //Show no search results message
                }
                
                //reload the tableView after the user searches
                [self.tableView reloadData];
            } else {
                
            }
        }];
    } else {
        self.isShowingSearchResults = NO;
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.isShowingSearchResults = NO;
    self.searchResults = @[];
    [self.tableView reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        self.isShowingSearchResults = NO;
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"EmbedSpotlightSegue"]) {
//        [(SpotlightFeedViewController*)[segue destinationViewController] setUser:self.friends[[self.tableView indexPathForCell:sender].row]];
//    }
    if (self.isShowingSearchResults) {
        [(FriendProfileViewController*)[segue destinationViewController] setUser:self.searchResults[[self.tableView indexPathForCell:sender].row]];
    } else {
        [(FriendProfileViewController*)[segue destinationViewController] setUser:self.friends[[self.tableView indexPathForCell:sender].row]];
    }
}



@end
