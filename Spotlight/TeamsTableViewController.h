//
//  TeamsTableViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface TeamsTableViewController : UITableViewController

- (void)reloadTable;

@property (strong, nonatomic) User* user;
@property (assign, nonatomic) BOOL isCurrentUser;

@end
