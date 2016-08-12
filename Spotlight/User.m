//
//  User.m
//  Spotlight
//
//  Created by Peter Kamm on 12/5/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "User.h"
#import "Team.h"

@implementation User

@dynamic profilePic;
@dynamic firstName;
@dynamic lastName;
@dynamic friends;
@dynamic children;
@dynamic teams;
@dynamic teamsRequest;
#pragma mark - Parse Stuff


+ (void)load {
    [self registerSubclass];
}

- (NSString*)displayName {
    NSString* displayName = self.username;
    if (self.firstName) {
        displayName = self.firstName;
        if (self.lastName) {
            displayName = [NSString stringWithFormat:@"%@ %@", displayName, self.lastName];
        }
    }
    return displayName;
}

- (void)followTeamWithBlockCallback:(Team*)team completion:(PFBooleanResultBlock)block{
    [[self teams] addObject:team];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
        }
        if (block) {
            
            block(succeeded,nil);
        }
    }];
}


- (void)followTeam:(Team*)team completion:(void (^)(void))completion{
    
    [[self teams] addObject:team];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
        }
        if (completion) {
            completion();
        }
    }];
}

-(void)unfollowTeam:(Team*)team completion:(void (^)(void))completion{
    [[self teams] removeObject:team];
    __block NSMutableArray *childArray = [NSMutableArray new];
    [[[self children] query] findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        childArray = objects.mutableCopy;
        for (Child* child in objects){
            [child.teams removeObject:team];
            
        }
        
        [Child saveAllInBackground:childArray block:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded){
                // [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
            }
            if (completion) {
                
                completion();
            }
            
        }];

        
    }];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
             [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
        }
        if (completion) {
            
            completion();
        }
    }];
}
@end
