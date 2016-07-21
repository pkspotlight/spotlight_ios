//
//  User.h
//  Spotlight
//
//  Created by Peter Kamm on 12/5/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <Parse/Parse.h>
@class ProfilePictureMedia;
@class Team;

@interface User : PFUser <PFSubclassing>

@property (strong, nonatomic) ProfilePictureMedia* profilePic;
@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (readonly, nonatomic) PFRelation* friends;
@property (readonly, nonatomic) PFRelation* children;
@property (readonly, nonatomic) PFRelation* teams;
@property (readonly, nonatomic) PFRelation* teamsRequest;

- (NSString*)displayName;
- (void)followTeam:(Team*)team completion:(void (^)(void))completion;
-(void)unfollowTeam:(Team*)team completion:(void (^)(void))completion;

@end
