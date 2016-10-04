//
//  Child.h
//  Spotlight
//
//  Created by Peter Kamm on 2/10/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import <Parse/Parse.h>

//@class ProfilePictureMedia;
#import "User.h"
#import "ProfilePictureMedia.h"
@class Team;
@interface Child : PFObject <PFSubclassing>

@property (strong, nonatomic) ProfilePictureMedia* profilePic;
@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSString* hometown;

@property (strong, nonatomic) NSDate* birthDate;
@property (readonly, nonatomic) PFRelation* friends;
@property (readonly, nonatomic) PFRelation* teams;

- (NSString*)displayName;
- (void)followTeam:(Team*)team completion:(void (^)(void))completion;
- (void)unfollowTeam:(Team*)team completion:(void (^)(void))completion;
- (void)followTeamWithBlockCallback:(Team*)team completion:(PFBooleanResultBlock)block;
//- (void)followTeamWithBlockCallback:(Team*)team withSpectator:(BOOL)isParticipant completion:(PFBooleanResultBlock)block;
@end
