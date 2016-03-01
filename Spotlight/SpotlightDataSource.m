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
#import "Child.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface SpotlightDataSource ()

@property (strong, nonatomic) NSArray *spotlights;
@property (strong, nonatomic) User* user;
@property (strong, nonatomic) Team* team;
@property (strong, nonatomic) Child* child;
@property (strong, nonatomic) NSDateFormatter* dateFormatter;

@end


@implementation SpotlightDataSource

- (instancetype)init{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithUser:(User*)user{
    if (self = [super init]) {
        [self commonInit];
        self.user = user;
    }
    return self;
}

- (instancetype)initWithTeam:(Team*)team{
    if (self = [super init]) {
        [self commonInit];
        self.team = team;
    }
    return self;
}

- (instancetype)initWithChild:(Child*)child{
    if (self = [super init]) {
        [self commonInit];
        self.child = child;
    }
    return self;
}

- (void)commonInit {
    self.team = nil;
    self.user = nil;
    self.child = nil;
    self.spotlights = [NSArray array];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.timeStyle = NSDateFormatterNoStyle;
    self.dateFormatter.dateStyle = NSDateFormatterLongStyle;
}

- (void)loadSpotlights:(void (^ __nullable)(void))completion{
    if (self.user) {
        [self loadTeamSpotlightsForUser:self.user completion:completion];
    }else if (self.child) {
        [self loadTeamSpotlightsForChild:self.child completion:completion];
    } else if (self.team) {
        [self loadTeamSpotlights:self.team completion:completion];
    } else {
        [self loadTeamSpotlightsForUser:[User currentUser] completion:completion];
    }
}

- (void)loadTeamSpotlightsForChild:(Child*)child completion:(void (^ __nullable)(void))completion{

    PFQuery *teamQuery = [[child teams] query];
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
            self.spotlights = [self.spotlights arrayByAddingObjectsFromArray:objects];
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

- (void)loadTeamSpotlightsForUser:(User*)user
                       completion:(void (^ __nullable)(void))completion{
    
    PFQuery *teamQuery = [[user teams] query];
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
            [self loadSpotlightsForChildren:[user children]
                                 completion:completion];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            if (completion) completion();
        }
    }];
}

- (void)loadSpotlightsForChildren:(PFRelation*)children
                       completion:(void (^ __nullable)(void))completion{
    [[children query] findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        for (Child* child in objects) {
            [self synchronouslyLoadSpotlightForChild:child];
        }
        // add error checking here
        if (completion) completion();
    }];
    
}

- (void)synchronouslyLoadSpotlightForChild:(Child*)child{
    PFQuery *teamQuery = [[child teams] query];
    [teamQuery includeKey:@"teamLogoMedia"];
    [teamQuery includeKey:@"thumbnailImageFile"];
    
    PFQuery *spotlightQuery = [PFQuery queryWithClassName:@"Spotlight"];
    [spotlightQuery includeKey:@"team"];
    [spotlightQuery includeKey:@"teamLogoMedia"];
    [spotlightQuery includeKey:@"thumbnailImageFile"];
    [spotlightQuery whereKey:@"team" matchesKey:@"objectId" inQuery:teamQuery];
    NSArray* newSpotlights = [spotlightQuery findObjects];
    for (Spotlight* spotlight in newSpotlights) {
        [self addUniqueSpotlight:spotlight];
    }
}

- (void)addUniqueSpotlight:(Spotlight*)nextSpotlight {
    
    for (Spotlight* spotlight in self.spotlights) {
        if ([nextSpotlight.objectId isEqualToString:spotlight.objectId]) {
            return;
        }
    }
    self.spotlights = [self.spotlights arrayByAddingObject:nextSpotlight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.spotlights.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SpotlightTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SpotlightTableViewCell" forIndexPath:indexPath];
    [cell formatForSpotlight:self.spotlights[indexPath.row] dateFormat:self.dateFormatter];
    return cell;
}

@end
