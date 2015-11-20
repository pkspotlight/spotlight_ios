//
//  SpotlightMediaCollectionViewCell.h
//  Spotlight
//
//  Created by Peter Kamm on 11/20/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpotlightMedia;

@interface SpotlightMediaCollectionViewCell : UICollectionViewCell

- (void)formatCellForSpotlightMedia:(SpotlightMedia*)media;

@end
