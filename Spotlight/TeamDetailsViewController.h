//
//  TeamDetailsViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 12/8/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsTableViewController.h"

@class Team;

@interface TeamDetailsViewController : UIViewController<TeamMembersdelegate>

@property (strong, nonatomic) Team* team;
@property (strong,nonatomic) NSMutableArray *teamMembersArray;

@end
