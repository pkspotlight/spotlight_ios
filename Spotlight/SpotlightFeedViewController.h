//
//  SpotlightFeedViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 9/7/15.
//  Copyright (c) 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse.h"

@interface SpotlightFeedViewController : UITableViewController

- (void)loadSpotlights;

@property(strong, nonatomic) PFUser* user;

@end
