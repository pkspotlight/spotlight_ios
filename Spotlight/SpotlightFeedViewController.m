//
//  SpotlightFeedViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 9/7/15.
//  Copyright (c) 2015 Spotlight. All rights reserved.
//

#import "SpotlightFeedViewController.h"
#import "Spotlight.h"
#import "SpotlightTableViewCell.h"
#import "SpotlightMedia.h"
#import "SpotlightTableViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface SpotlightFeedViewController ()

@property (strong, nonatomic) NSArray *spotlights;

@end

@implementation SpotlightFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.spotlights = [NSArray array];
    if (!self.user) self.user = [PFUser currentUser];
    [self loadSpotlights];
}

- (void)showFriends:(id)sender {
    
    [self performSegueWithIdentifier:@"friendsVCSegue" sender:sender];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    return self.spotlights.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SpotlightTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SpotlightTableViewCell" forIndexPath:indexPath];
    [cell formatForSpotlight:self.spotlights[indexPath.row]];
    return cell;
}

- (void)loadSpotlights {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Spotlight"];
    [query whereKey:@"spotlightParticipant" equalTo:[self.user objectId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu Spotlights.", (unsigned long)objects.count);
            
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
            }
            self.spotlights = objects;
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}
//
//- (IBAction)unwindThing:(UIStoryboardSegue*)sender {
//    
//}

- (IBAction)unwindCreation:(UIStoryboardSegue*)sender {
    
    [self loadSpotlights];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"SpotlightSegue"]) {
        [(SpotlightTableViewController*)[segue destinationViewController] setSpotlight:self.spotlights[[self.tableView indexPathForCell:sender].row]];
    }
}


@end
