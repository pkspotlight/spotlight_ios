//
//  TeamFinderTableViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 2/19/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TeamTableViewCell;

@interface TeamFinderTableViewController : UITableViewController

- (void)followButtonPressed:(TeamTableViewCell*)teamCell;

@end
