//
//  FriendsTableViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 11/5/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TeamMembersdelegate <NSObject>

-(void)getTeamMembers:(NSMutableArray*)teamMembers;


@end
@class User;
@class Team;

@interface FriendsTableViewController : UITableViewController

@property (strong, nonatomic) User* user;
@property (strong, nonatomic) Team* team;
@property (weak,atomic) id <TeamMembersdelegate> delegate;
@property (assign, nonatomic) BOOL justFamily;

@end
