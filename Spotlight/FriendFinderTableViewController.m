//
//  FriendFinderTableViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 2/8/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import "FriendFinderTableViewController.h"
#import "FriendProfileViewController.h"
#import "FriendTableViewCell.h"
#import "Parse.h"
#import "User.h"
#import "BasicHeaderView.h"


@interface FriendFinderTableViewController ()
{
    UIRefreshControl* refresh;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (strong, nonatomic) NSArray* searchResults;
@property (strong, nonatomic) NSMutableArray* friendsArray;
@property (strong, nonatomic) UITapGestureRecognizer* hideKeyboardTap;

@end

@implementation FriendFinderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.friendsArray = [NSMutableArray new];
    [self.tableView registerNib:[UINib nibWithNibName:@"BasicHeaderView" bundle:nil]
forHeaderFooterViewReuseIdentifier:@"BasicHeaderView"];
    refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refresh];
    [self loadFriends];
    if([self.controllerType intValue]==1&&self.controllerType!=nil){
        self.navigationItem.title = @"Send Invites";
        
    }else{
        
    }
    
    self.hideKeyboardTap = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(dismissKeyboard)];
}

- (void)loadFriends{
    PFQuery *query = [[User currentUser].friends query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.friendsArray = [objects copy];
        
    }];
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
        cell = (FriendTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"FriendTableViewCell"
                                                                     forIndexPath:indexPath];
        
        
        
        bool isFollowing = false;
     
        User *user = (User*)self.searchResults[indexPath.row];
        
        if([user.objectId isEqualToString:[User currentUser].objectId ]){
            [(FriendTableViewCell*)cell followButton].hidden = YES;
          
        }
        else{
           // [(FriendTableViewCell*)cell followButton].hidden = NO;
            
            if([self.controllerType intValue]==1&&self.controllerType!=nil){
                [(FriendTableViewCell*)cell followButton].hidden = YES;
                [(FriendTableViewCell*)cell inviteButton].hidden = NO;
                FriendTableViewCell *friendCell = (FriendTableViewCell*)cell;
                friendCell.team = self.selectedTeam;
                
            }else{
                [(FriendTableViewCell*)cell followButton].hidden = NO;
                [(FriendTableViewCell*)cell inviteButton].hidden = YES;
            }

            
          
            if(([[self.friendsArray valueForKeyPath:@"objectId"] containsObject:user.objectId]))
            {
                isFollowing = true;
                
                
            }
            else{
                isFollowing = false;
                }

        }
        
        
        [(FriendTableViewCell*)cell formatForUser:self.searchResults[indexPath.row] isSpectator:NO  isFollowing:isFollowing];
       
    }
    return cell;
}


#pragma mark - SearchBar Delegate Methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    //dismiss keyboard
    [self.searchBar resignFirstResponder];
    
    //Strip the whitespace off the end of the search text
    NSArray* components = [self.searchBar.text componentsSeparatedByString:@" "];
//    NSString *searchText = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![components[0] isEqualToString:@""]) {
        PFQuery *firstQuery = [User query];
        PFQuery *secondQuery = [User query];
        PFQuery *usernameQuery = [User query];
        PFQuery *emailQuery = [User query];
        PFQuery *lastNameQuery = [User query];

        
        [firstQuery whereKey:@"firstName" containsString:components[0]];
        [secondQuery whereKey:@"lastName" containsString:components[0]];
        [usernameQuery whereKey:@"username" containsString:[components[0] lowercaseString]];
        [emailQuery whereKey:@"email" containsString:[components[0] lowercaseString]];
        
        PFQuery *query;
        if (components.count > 1) {
            [lastNameQuery whereKey:@"lastName" containsString:components[1]];
            query = [PFQuery orQueryWithSubqueries:@[firstQuery,
                                                     secondQuery,
                                                     usernameQuery,
                                                     emailQuery,
                                                     lastNameQuery]];
        }else {
            query = [PFQuery orQueryWithSubqueries:@[firstQuery,
                                                     secondQuery,
                                                     usernameQuery,
                                                     emailQuery]];
        }
        [refresh beginRefreshing];

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
            
            [refresh performSelectorOnMainThread:@selector(endRefreshing) withObject:nil waitUntilDone:NO];

        }];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchResults = @[];
    [self.tableView reloadData];
    [refresh endRefreshing];

}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        self.searchResults = @[];
        [self.tableView reloadData];
    }
}


-(void)refresh{
    [refresh endRefreshing];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    User *user = (User*)self.searchResults[indexPath.row];
//    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    FriendProfileViewController *friendProfileViewController = [storyboard instantiateViewControllerWithIdentifier:@"FriendsProfile"];
//    [friendProfileViewController setUser:user];
//    [self.navigationController pushViewController:friendProfileViewController animated:YES];
    
    
    
    
    
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



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    

    
    
 

}

@end
