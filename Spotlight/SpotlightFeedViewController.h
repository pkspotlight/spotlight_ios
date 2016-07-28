//
//  SpotlightFeedViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 9/7/15.
//  Copyright (c) 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse.h"
#import "SpotlightDataSource.h"
@class User;
@class SpotlightDataSource;

@interface SpotlightFeedViewController : UITableViewController<RefreshTableDelegate,UITableViewDelegate>

@property (strong, nonatomic) SpotlightDataSource *dataSource;

@end
