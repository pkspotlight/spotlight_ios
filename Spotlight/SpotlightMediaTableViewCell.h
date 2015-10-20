//
//  SpotlightMediaTableViewCell.h
//  Spotlight
//
//  Created by Peter Kamm on 10/20/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotlightMedia.h"

@interface SpotlightMediaTableViewCell : UITableViewCell

- (void)formatWithSpotlightMedia:(SpotlightMedia*)spotlightMedia;
@end
