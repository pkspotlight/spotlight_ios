//
//  TeamsTableViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeamTableViewCell.h"

@class User;
@class Child;

@interface TeamsTableViewController : UITableViewController <TeamTableViewCellDelegate>

- (void)reloadTable;
- (void)followButtonPressed:(TeamTableViewCell*)teamCell completion:(void (^)(void))completion;

@property (strong, nonatomic) User* user;
@property (strong, nonatomic) Child* child;
@property (assign, nonatomic) BOOL isFollowingShow;

@end
