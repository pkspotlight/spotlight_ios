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
#import "SpotlightCollectionViewController.h"
#import "SpotlightMedia.h"
#import "User.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface SpotlightFeedViewController ()

@property (strong, nonatomic) NSArray *spotlights;

@end

@implementation SpotlightFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refresh];
    self.spotlights = [NSArray array];
    if (!self.user) self.user = [User currentUser];
    [self loadSpotlights:nil];
}

- (void)refresh:(id)sender {
    
    [self loadSpotlights:(UIRefreshControl*)sender];
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

- (void)loadSpotlights:(UIRefreshControl*)sender {
    
    PFQuery *teamQuery = [PFQuery queryWithClassName:@"Team"];
    [teamQuery whereKey:@"teamParticipants" equalTo:[self.user objectId]];
    [teamQuery includeKey:@"teamLogoMedia"];
    [teamQuery includeKey:@"thumbnailImageFile"];

    PFQuery *spotlightQuery = [PFQuery queryWithClassName:@"Spotlight"];
    [spotlightQuery includeKey:@"team"];
    [spotlightQuery includeKey:@"teamLogoMedia"];
    [spotlightQuery includeKey:@"thumbnailImageFile"];

    [spotlightQuery whereKey:@"team" matchesKey:@"objectId" inQuery:teamQuery];
    [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu Spotlights.", (unsigned long)objects.count);
            self.spotlights = objects;
            [self.tableView reloadData];
            [sender endRefreshing];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
//    PFQuery *query = [PFQuery queryWithClassName:@"Spotlight"];
//    [query whereKey:@"spotlightParticipant" equalTo:[self.user objectId]];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            NSLog(@"Successfully retrieved %lu Spotlights.", (unsigned long)objects.count);
//            
//            for (PFObject *object in objects) {
//                NSLog(@"%@", object.objectId);
//            }
//            self.spotlights = objects;
//            [self.tableView reloadData];
//            [sender endRefreshing];
//        } else {
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
}

- (IBAction)unwindCreation:(UIStoryboardSegue*)sender {
    
    [self loadSpotlights:nil];
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"SpotlightSegue"]) {
        [(SpotlightCollectionViewController*)[segue destinationViewController] setSpotlight:self.spotlights[[self.tableView indexPathForCell:sender].row]];
    }
}


@end
