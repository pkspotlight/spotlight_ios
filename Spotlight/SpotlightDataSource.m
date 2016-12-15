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

@interface SpotlightDataSource (){

}

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
    
    _doesCheckForPrivacy = true;
    if (self.user) {
        _doesCheckForPrivacy = true;
        [self loadTeamSpotlightsForUser:self.user completion:completion];
    }else if (self.child) {
        _doesCheckForPrivacy = true;

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
    [spotlightQuery orderByDescending:@"createdAt"];
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
    [spotlightQuery orderByDescending:@"createdAt"];
    [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu Spotlights.", (unsigned long)objects.count);
            self.spotlights = [self sortSpotlightsByCreatedDate:objects];
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
    
//    [spotlightQuery whereKey:@"team" matchesKey:@"objectId" inQuery:teamQuery];
    [spotlightQuery whereKey:@"team" matchesQuery:teamQuery];
    [spotlightQuery orderByDescending:@"createdAt"];

    [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu Spotlights.", (unsigned long)objects.count);
            self.spotlights = [self sortSpotlightsByCreatedDate:objects];
//            [self loadSpotlightsForChildren:[user children]
//                                 completion:completion];
             if (completion) completion();
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            if (completion) completion();
        }
    }];
}

- (void)loadSpotlightsForChildren:(PFRelation*)children
                       completion:(void (^ __nullable)(void))completion{
    [[children query] findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        long childCount = objects.count;
        if(childCount == 0)
        {
            self.spotlights = [self sortSpotlightsByCreatedDate:self.spotlights];
            
            // add error checking here
            if (completion) completion();
            return;
        }
      __block  long initialCount = 0;
        
        for (Child* child in objects) {
            [self synchronouslyLoadSpotlightForChild:child completion:^{
                
                initialCount++;
                if(initialCount == childCount)
                {
                    self.spotlights = [self sortSpotlightsByCreatedDate:self.spotlights];
                    
                    // add error checking here
                    if (completion) completion();
                }
                
            }];
        }
       
        
        
    }];
    
}

- (NSArray*)sortSpotlightsByCreatedDate:(NSArray*)spotlights {
    return [spotlights sortedArrayUsingComparator:^NSComparisonResult(Spotlight*  _Nonnull obj1, Spotlight*  _Nonnull obj2) {
        if ([[obj1.createdAt laterDate:obj2.createdAt] isEqualToDate:obj1.createdAt]) {
            return (NSComparisonResult)NSOrderedAscending;
        } else {
            return (NSComparisonResult)NSOrderedDescending;
        }
    }];
}

- (void)synchronouslyLoadSpotlightForChild:(Child*)child completion:(void (^ __nullable)(void))completion
{
    PFQuery *teamQuery = [[child teams] query];
    [teamQuery includeKey:@"teamLogoMedia"];
    [teamQuery includeKey:@"thumbnailImageFile"];
    
    PFQuery *spotlightQuery = [PFQuery queryWithClassName:@"Spotlight"];
    [spotlightQuery includeKey:@"team"];
    [spotlightQuery includeKey:@"teamLogoMedia"];
    [spotlightQuery includeKey:@"thumbnailImageFile"];
    [spotlightQuery whereKey:@"team" matchesKey:@"objectId" inQuery:teamQuery];
    [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error)
        {
        for (Spotlight* spotlight in objects) {
            [self addUniqueSpotlight:spotlight];
        }
        }
        if(completion) completion();
    }];
    
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
    
    
    Spotlight *spotLight = self.spotlights[indexPath.row];
    
    
        SpotlightTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SpotlightTableViewCell" forIndexPath:indexPath];
        [cell formatForSpotlight:spotLight dateFormat:self.dateFormatter];
        return cell;
   
    
    
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SpotlightTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell)
    {
        return cell.isEditingAllowed;
    }
    return true;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    Spotlight *spotlight = [self.spotlights objectAtIndex:indexPath.row];
    __block BOOL isCreatedByCurrentUser = false;
    PFQuery* moderatorQuery = [spotlight.moderators query];
    [moderatorQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        for (User* user in objects) {
            if ([user.objectId isEqualToString:[[User currentUser] objectId]]) {
                isCreatedByCurrentUser = true;
                
                
                if(isCreatedByCurrentUser)
                {
                    if (editingStyle == UITableViewCellEditingStyleDelete) {
                        //        //add code here for when you hit delete
                        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Are You Sure ?"
                                                                          message:nil
                                                                         delegate:self
                                                                cancelButtonTitle:@"Yes"
                                                                otherButtonTitles:@"No",nil];
                        message.accessibilityValue = @"Delete";
                        message.tag = indexPath.row;
                        [message show];
                        
                    }
                }
                

                
                
                
            }
        }
        
        if(!isCreatedByCurrentUser)
        {
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }];
    
    }



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.accessibilityValue isEqualToString:@"Delete"]){
        if(buttonIndex ==0){
            Spotlight *spotlight = [self.spotlights objectAtIndex:alertView.tag];
//            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:YES];
//            [hud setLabelText:@"Deleting Spotlight..."];
            
            [spotlight deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded){
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
                   // [self.delegate spotlightDeleted:hud];
                }
            }];
        }
    }
    
}

@end
