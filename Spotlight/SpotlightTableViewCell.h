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

- (void)formatForSpotlight:(Spotlight*)spotlight dateFormat:(NSDateFormatter*)dateFormatter;

@property (strong, nonatomic) Spotlight* spotlight;
@property (assign) BOOL isEditingAllowed;
@end
