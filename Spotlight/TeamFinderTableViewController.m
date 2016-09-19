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
{
    UIRefreshControl* refresh;
    NSMutableArray *pendingRequestArray;
    NSMutableArray *filteredArrayOfObjects;

}
//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITextField *searchTxtField;
@property (weak, nonatomic) IBOutlet UIImageView *searchImage;
@property (weak, nonatomic) IBOutlet UIButton *crossImage;

@property (strong, nonatomic) NSMutableArray *teams;
@property (strong, nonatomic) NSArray* searchResults;
@property (strong, nonatomic) UITapGestureRecognizer* hideKeyboardTap;
@end

@implementation TeamFinderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pendingRequestArray = [NSMutableArray new];
    filteredArrayOfObjects = [[NSMutableArray alloc] init];
    _teams = [[NSMutableArray alloc] init];
    [self fetchAllPendingRequest];
    [self loadUserTeams:nil];
    [self.tableView registerNib:[UINib nibWithNibName:@"BasicHeaderView" bundle:nil]
forHeaderFooterViewReuseIdentifier:@"BasicHeaderView"];
    refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refresh];
    self.hideKeyboardTap = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(dismissKeyboard)];
}



- (void)loadUserTeams:(UIRefreshControl*)sender  {
    PFQuery *query = [[[User currentUser] teams] query];
    [query includeKey:@"teamLogoMedia"];
    [query orderByDescending:@"year"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved my %lu Teams.", (unsigned long)objects.count);
            [self.teams addObjectsFromArray:[objects copy]];
            
            [self sortTeamsArray:self.teams];
            PFQuery *query = [[User currentUser].children query];
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
    [filteredArrayOfObjects removeAllObjects];
    
    for (Team *team in sortedArray)
    {
        if(!([[filteredArrayOfObjects valueForKeyPath:@"objectId"] containsObject:team.objectId]))
        {
            [filteredArrayOfObjects addObject:team];
        }
    }
    
    self.teams = filteredArrayOfObjects;
    
    // [NSMutableArray arrayWithArray:sortedArray];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.searchResults.count == 0) ? 1 : self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    if ([self.searchResults count] == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NoResultsTableViewCell"
                                               forIndexPath:indexPath];
        if (self.searchResults == nil) {
            cell.contentView.hidden = YES;
        }else{
            cell.contentView.hidden = NO;
        }
        
    } else {
        cell = (TeamTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"TeamTableViewCell"
                                                                   forIndexPath:indexPath];
        
        
        
        bool isFollowing = false;
        Team *team = (Team*)self.searchResults[indexPath.row];


        if(([[self.teams valueForKeyPath:@"objectId"] containsObject:team.objectId]))
        {
            isFollowing = true;
            
            
        }
        else{
            isFollowing = false;
        }

        [(TeamTableViewCell*)cell formatForTeam:self.searchResults[indexPath.row] isFollowing:isFollowing];
        
        [(TeamTableViewCell*)cell setDelegate:self];
    }
    return cell;
}




#pragma mark - SearchBar Delegate Methods

//-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    //dismiss keyboard
//    [self.searchBar resignFirstResponder];
//    
//    //Strip the whitespace off the end of the search text
//    NSString *searchText = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    
//    if (![searchText isEqualToString:@""]) {
//        
//        [refresh beginRefreshing];
//        
//        PFQuery *firstQuery = [Team query];
//        PFQuery *secondQuery = [Team query];
//        
//        [firstQuery whereKey:@"teamName" containsString:searchText];
//        [secondQuery whereKey:@"town" containsString:searchText];
//        
//        PFQuery *query = [PFQuery orQueryWithSubqueries:@[firstQuery,
//                                                          secondQuery]];
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            if (!error) {
//                self.searchResults = objects;
//                if (objects.count > 0) {
//                    for (Team *team in objects) {
//                        NSLog(@"team: %@, %@", team.teamName, team.town);
//                    }
//                } else {
//                    //Show no search results message
//                }
//                
//                //reload the tableView after the user searches
//                [self.tableView reloadData];
//            } else {
//                
//            }
//            [refresh performSelectorOnMainThread:@selector(endRefreshing) withObject:nil waitUntilDone:NO];
//        }];
//    }
//}
//


-(void)searchText:(NSString*)searchTeamText{
  //  [self.searchBar resignFirstResponder];
    
    //Strip the whitespace off the end of the search text
    NSString *searchText = [searchTeamText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![searchText isEqualToString:@""]) {
        
        [refresh beginRefreshing];
        
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
                        NSLog(@"team: %@, %@", team.teamName, team.town);
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


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString *txtToSearch = [NSString new];
    NSString *substring = [NSString stringWithString:self.searchTxtField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    txtToSearch = substring;
    
    
    if([txtToSearch isEqualToString:@""] && txtToSearch.length == 0){
        self.searchResults = @[];
        [self.crossImage setHidden:YES];
        
        [self.tableView reloadData];
        
    }
    else{
        [self.crossImage setHidden:NO];
    }
    
    
    
    
    return YES; //If you don't your textfield won't get any text in it
}


-(IBAction)searchCancelButtonClicked:(UIButton *)sender {
    self.searchResults =  nil;
    [self.crossImage setHidden:YES];
    
    self.searchTxtField.text = @"";
    [self.tableView reloadData];
    [refresh endRefreshing];
}

- (IBAction)backButtonClicked:(UIBarButtonItem*)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}





- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self searchText:textField.text];
    [textField resignFirstResponder];
    return YES;
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.view removeGestureRecognizer:self.hideKeyboardTap];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.view addGestureRecognizer:self.hideKeyboardTap];
    
}




-(void)refresh{
    [refresh endRefreshing];
}

//-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    self.searchResults = @[];
//    [self.tableView reloadData];
//    [refresh endRefreshing];
//
//}

//-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//    if ([searchText isEqualToString:@""]) {
//        self.searchResults = @[];
//        [self.tableView reloadData];
//    }
//}
//
//-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    [self.view addGestureRecognizer:self.hideKeyboardTap];
//}
//
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
//    [self.view removeGestureRecognizer:self.hideKeyboardTap];
//}

- (void) dismissKeyboard {
    [self.searchTxtField resignFirstResponder];
}

-(void)fetchAllPendingRequest{
    
        PFQuery *spotlightQuery = [PFQuery queryWithClassName:@"TeamRequest"];
        [spotlightQuery whereKey:@"user" equalTo:[User currentUser]];
        
        [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(objects.count > 0)
            {
               // NSMutableArray *array = [NSMutableArray new];
                for(TeamRequest *request in objects)
                {
                    if((request.requestState.intValue == reqestStatePending))
                    {
                        
                        [pendingRequestArray addObject:request];

                        [request.team fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                                            //   NSString *data =[NSString stringWithFormat:@"%@       %@",request.admin.firstName,request.user.firstName];
                          
                            
                                        }];
                                            }
                    
                }
                
                
            }
            else{
                //[[[self  tabBar]items] objectAtIndex:2].badgeValue  = nil;
            }
            
            //        for(TeamRequest *request in objects)
            //        {
            //            [request.admin fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            //                //   NSString *data =[NSString stringWithFormat:@"%@       %@",request.admin.firstName,request.user.firstName];
            //                
            //                NSLog(@"%@",request.admin.firstName);
            //            }];
            //            
            //            
            //            
            //        }
            
        }];
        
    }



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
                                                
                                                [[User currentUser] unfollowTeam:teamCell.team completion:completion];
                                                
                                                
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
                                                    
                                                    PFQuery* moderatorQuery = [team.moderators query];
                                                    [moderatorQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                                                        if(objects.count==0){
                                                            [[[UIAlertView alloc] initWithTitle:@""
                                                                                        message:@"No admin found for this team"
                                                                                       delegate:nil
                                                                              cancelButtonTitle:nil
                                                                              otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
                                                        }
                                                        
                                                        else{
                                                            for (User* user in objects) {
                                                                
                                                                if(![self isRequestAllowed:NO withUser:user withChild:nil withTeam:team]){
                                                                    [[[UIAlertView alloc] initWithTitle:@""
                                                                                                message:@"A request to follow this team is already sent to admin."
                                                                                               delegate:nil
                                                                                      cancelButtonTitle:nil
                                                                                      otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
                                                                }
                                                                
                                                                else{
                                                                    NSString *timestamp =  [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
                                                                    
                                                                    TeamRequest *teamRequest = [[TeamRequest alloc]init];
                                                                    
                                                                    [teamRequest saveTeam:team andAdmin:user  followby:[User currentUser] orChild:nil withTimestamp:timestamp isChild:@0 isType:@1  completion:^{
                                                                        if (completion) {
                                                                          
                                                                            completion();
                                                                        }
                                                                          [pendingRequestArray addObject:teamRequest];
                                                                          [self.tableView reloadData];
                                                                    }];
                                                                    break;

                                                                }
                                                               
                                                                
                                                                
                                                            }
                                                        }
                                                    }];
                                                    
                                                    
                                                    
                                                    //                                                    [[User currentUser] followTeam:team completion:^{
                                                    //                                                        if (completion) {
                                                    //
                                                    //                                                            completion();
                                                    //                                                        }
                                                    //                                                    }];
                                                }]];
        for (Child* child in children) {
            [alert addAction:[UIAlertAction actionWithTitle:[child displayName]
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        
                                                        PFQuery* moderatorQuery = [team.moderators query];
                                                        [moderatorQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                                                            if(objects.count==0){
                                                                [[[UIAlertView alloc] initWithTitle:@""
                                                                                            message:@"No admin found for this team."
                                                                                           delegate:nil
                                                                                  cancelButtonTitle:nil
                                                                                  otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
                                                            }
                                                            
                                                            else{
                                                                for (User* user in objects) {
                                                                    
                                                                    if(![self isRequestAllowed:YES withUser:nil withChild:child withTeam:team]){
                                                                        [[[UIAlertView alloc] initWithTitle:@""
                                                                                                    message:@"A request to follow this team is already sent to admin."
                                                                                                   delegate:nil
                                                                                          cancelButtonTitle:nil
                                                                                          otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
                                                                    }
                                                                    
                                                                    else{
                                                                  
                                                                        NSString *timestamp =  [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
                                                                        
                                                                        TeamRequest *teamRequest = [[TeamRequest alloc]init];
                                                                        
                                                                        [teamRequest saveTeam:team andAdmin:user  followby:[User currentUser] orChild:child withTimestamp:timestamp isChild:@1 isType:@1 completion:^{
                                                                            if (completion) {
                                                                                
                                                                                completion();
                                                                            }
                                                                            [pendingRequestArray addObject:teamRequest];
                                                                             [self.tableView reloadData];
                                                                        }];
                                                                        break;
                                                                        
                                                                                                                                   }
                                                                    
                                                                }
                                                            }
                                                        }];
                                                        
                                                        
                                                        
                                                        //                                                        [child followTeam:team completion:^{
                                                        //                                                            if (completion) {
                                                        //
                                                        //                                                                completion();
                                                        //                                                            }
                                                        //                                                        }];
                                                    }]];
        }
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        
        PFQuery* moderatorQuery = [team.moderators query];
        [moderatorQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if(objects.count==0){
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:@"No admin found for this team."
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
            }
            
            else{
                for (User* user in objects) {
                    
                    if(![self isRequestAllowed:NO withUser:[User currentUser] withChild:nil withTeam:team]){
                        [[[UIAlertView alloc] initWithTitle:@""
                                                    message:@"A request to follow this team is already sent to admin."
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
                    }
                    else{
                   
                        NSString *timestamp =  [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
                    
                        TeamRequest *teamRequest = [[TeamRequest alloc]init];
                    
                        [teamRequest saveTeam:team andAdmin:user  followby:[User currentUser] orChild:nil withTimestamp:timestamp isChild:@0 isType:@1 completion:^{
                            if (completion) {
                                
                                completion();
                            }
                              [pendingRequestArray addObject:teamRequest];
                             [self.tableView reloadData];
                        }];
                        break;
                        
                    
                }
                }
            }
        }];
        

        
        
        
        //        [[User currentUser] followTeam:team completion:^{
        //            if (completion) {
        //
        //                completion();
        //            }
        //        }];
    }
}


-(BOOL)isRequestAllowed:(BOOL)isChild withUser:(User*)user withChild:(Child*)child withTeam:(Team*)team {
    
    if(!isChild){
        for(TeamRequest *request in pendingRequestArray){
            
            if((!request.isChild.boolValue)&&([request.team.objectId isEqualToString:team.objectId])){
                return NO;
            }
        
    }
        
        return YES;

    }
    else{
        for(TeamRequest *request in pendingRequestArray){
            
            if(([child.objectId isEqualToString:request.child.objectId])&&([request.team.objectId isEqualToString:team.objectId])&& (request.isChild.boolValue)){
                
                return NO;
                
            
            
            }

            
           
            
            
        }
            return YES;

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
