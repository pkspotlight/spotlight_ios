//
//  SpotlightTableViewCell.h
//  Spotlight
//
//  Created by Peter Kamm on 10/19/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Spotlight.h"

@interface SpotlightTableViewCell : UITableViewCell

- (void)formatForSpotlight:(Spotlight*)spotlight;

@property (strong, nonatomic) Spotlight* spotlight;

@end
