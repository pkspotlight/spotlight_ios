//
//  ChildTableViewCell.h
//  Spotlight
//
//  Created by Peter Kamm on 2/10/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Child;

@interface ChildTableViewCell : UITableViewCell

- (void)formatForChild:(Child*)child isFollowing:(BOOL)isFollowing;

@end
