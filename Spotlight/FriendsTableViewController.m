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
#import "BasicHeaderView.h"

static CGFloat const BasicHeaderHeight = 50;


@interface FriendsTableViewController ()

@property (strong, nonatomic) NSArray* friends;

@end

@implementation FriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"BasicHeaderView" bundle:nil]
forHeaderFooterViewReuseIdentifier:@"BasicHeaderView"];
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refresh];
    [refresh beginRefreshing];
    [self refresh:refresh];
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


- (IBAction)plusButtonPressed:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Add a New Spotlighter"
                                                                    message:@""
                                                             preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Search Spotlighters"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self performSegueWithIdentifier:@"SearchFriendsSegue"
                                                                          sender:sender];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Add Family Member"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self performSegueWithIdentifier:@"CreateFamilyMemberSegue"
                                                                          sender:sender];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                            }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BasicHeaderView *cell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"BasicHeaderView"];
    cell.headerTitleLabel.text = (section == 0) ? @"Family" : @"Friends";
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return BasicHeaderHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

        return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
        cell = (FriendTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"FriendTableViewCell"
                                                                     forIndexPath:indexPath];

            [(FriendTableViewCell*)cell formatForUser:self.friends[indexPath.row] isFollowing:YES];
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"FriendDetailsSegue"]) {
            [(FriendProfileViewController*)[segue destinationViewController] setUser:self.friends[[self.tableView indexPathForCell:sender].row]];
    } else if ([segue.identifier isEqualToString:@"SearchFriendsSegue"]) {
    } else if ([segue.identifier isEqualToString:@"CreateFamilyMemberSegue"]) {
    }
}

- (IBAction)unwindAddFriends:(UIStoryboardSegue*)sender {
    
}

- (IBAction)unwindCancelAddFamilyMember:(UIStoryboardSegue*)sender {
    
}

- (IBAction)unwindSaveFamilyMember:(UIStoryboardSegue*)sender {
    
}

@end
