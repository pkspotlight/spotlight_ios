//
//  FriendsTableViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 11/5/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;
@class Team;

@interface FriendsTableViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) User* user;
@property (strong, nonatomic) Team* team;

@end
