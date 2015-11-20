//
//  TeamTableViewCell.h
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Team;

@interface TeamTableViewCell : UITableViewCell

- (void)formatForTeam:(Team*)team isFollowing:(BOOL)isFollowing;

@property (readonly, nonatomic) Team* team;


@end
