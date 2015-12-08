//
//  SpotlightDataSource.m
//  Spotlight
//
//  Created by Peter Kamm on 12/8/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "SpotlightDataSource.h"
#import "Spotlight.h"
#import "SpotlightTableViewCell.h"
#import "SpotlightCollectionViewController.h"
#import "SpotlightMedia.h"
#import "User.h"
#import "Team.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface SpotlightDataSource ()

@property (strong, nonatomic) NSArray *spotlights;
@property (strong, nonatomic) User* user;
@property (strong, nonatomic) Team* team;


@end


@implementation SpotlightDataSource

- (instancetype)init{
    if (self = [super init]) {
        self.spotlights = [NSArray array];
        self.team = nil;
        self.user = nil;
    }
    return self;
}

- (instancetype)initWithUser:(User*)user{
    if (self = [super init]) {
        self.spotlights = [NSArray array];
        self.user = user;
        self.team = nil;
    }
    return self;
}

- (instancetype)initWithTeam:(Team*)team{
    if (self = [super init]) {
        self.spotlights = [NSArray array];
        self.team = team;
        self.user = nil;
    }
    return self;
}

- (void)loadSpotlights:(void (^ __nullable)(void))completion{
    if (self.team) {
        [self loadTeamSpotlights:self.team completion:completion];
    } else if (self.user) {
        [self loadTeamSpotlightsForUser:self.user completion:completion];
    }else {
        [self loadCurrentUserSpotlights:completion];
    }
}

- (void)loadCurrentUserSpotlights:(void (^ __nullable)(void))completion{
    User *user = [User currentUser];
    PFQuery *friendQuery = [user.friends query];
    
    PFQuery *teamQuery = [PFQuery queryWithClassName:@"Team"];
    [teamQuery whereKey:@"teamParticipants" equalTo:[[User currentUser] objectId]];
    [teamQuery whereKey:@"teamParticipants" matchesKey:@"objectId" inQuery:friendQuery];

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
            if (completion) completion();
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            if (completion) completion();
        }
    }];
}

- (void)loadTeamSpotlights:(Team*)team completion:(void (^ __nullable)(void))completion{
    PFQuery *spotlightQuery = [PFQuery queryWithClassName:@"Spotlight"];
    [spotlightQuery includeKey:@"team"];
    [spotlightQuery includeKey:@"teamLogoMedia"];
    [spotlightQuery includeKey:@"thumbnailImageFile"];
    [spotlightQuery whereKey:@"team" equalTo:team];
    [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu Spotlights.", (unsigned long)objects.count);
            self.spotlights = objects;
            if (completion) completion();
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            if (completion) completion();
        }
    }];
}

- (void)loadTeamSpotlightsForUser:(User*)user completion:(void (^ __nullable)(void))completion{
    
    PFQuery *teamQuery = [PFQuery queryWithClassName:@"Team"];
    [teamQuery whereKey:@"teamParticipants" equalTo:[user objectId]];
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
            if (completion) completion();
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            if (completion) completion();
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.spotlights.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SpotlightTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SpotlightTableViewCell" forIndexPath:indexPath];
    [cell formatForSpotlight:self.spotlights[indexPath.row]];
    return cell;
}

@end
