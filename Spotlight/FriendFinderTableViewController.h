//
//  FriendFinderTableViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 2/8/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"
@interface FriendFinderTableViewController : UITableViewController <UISearchBarDelegate,UITextFieldDelegate>
@property (strong, nonatomic) NSNumber* controllerType;
@property (strong, nonatomic) Team* selectedTeam;
@end
