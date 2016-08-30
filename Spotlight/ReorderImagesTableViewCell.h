//
//  ReorderImagesTableViewCell.h
//  Spotlight
//
//  Created by Aakash Gupta on 8/2/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotlightMedia.h"
@interface ReorderImagesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *spotlightPicImageView;
@property (weak, nonatomic) IBOutlet UILabel *imageTitle;

- (void)setDataSpotlight:(SpotlightMedia *)media;
@end
