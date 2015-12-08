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

@interface FriendsTableViewController ()

@property (strong, nonatomic) NSArray* friends;

@end

@implementation FriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadFriends];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)loadFriends {
    
    PFQuery *query = [(PFRelation*)[[PFUser currentUser] objectForKey:@"friends"] query];
    self.friends = [query findObjects];
    [self.tableView reloadData];

}
- (IBAction)addFriendButtonPressed:(id)sender {
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:@"Enter email of friend"
                                message:nil
                                preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setKeyboardType:UIKeyboardTypeEmailAddress];
    }];
    [alert addAction:[UIAlertAction
                      actionWithTitle:@"Add Friend"
                      style:UIAlertActionStyleDefault
                      handler:^(UIAlertAction * _Nonnull action) {
                          PFQuery *query = [PFUser query];
                          [query whereKey:@"username" equalTo:alert.textFields[0].text];
                          [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                              if (object) {
                                  PFRelation *participantRelation = [[PFUser currentUser] relationForKey:@"friends"];
                                  [participantRelation addObject:object];
                                  [[PFUser currentUser] save];
                                  [self loadFriends];
                              }else {
                                  UIAlertController* noUserAlert = [UIAlertController
                                                                    alertControllerWithTitle:@"User does not exist"
                                                                    message:nil
                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                  [noUserAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                                  [self presentViewController:noUserAlert animated:YES completion:nil];
                                  
                              }
                              
                          }];
                          
                      }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friends count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendTableViewCell" forIndexPath:indexPath];
    [cell formatForUser:self.friends[indexPath.row] isFollowing:NO];
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"EmbedSpotlightSegue"]) {
//        [(SpotlightFeedViewController*)[segue destinationViewController] setUser:self.friends[[self.tableView indexPathForCell:sender].row]];
//    }
    [(FriendProfileViewController*)[segue destinationViewController] setUser:self.friends[[self.tableView indexPathForCell:sender].row]];
}


@end
