//
//  SpotlightTableViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 10/20/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Spotlight.h"
#import "MWPhotoBrowser.h"

@interface SpotlightTableViewController : UITableViewController <MWPhotoBrowserDelegate>

@property (strong, nonatomic) Spotlight* spotlight;

@end
