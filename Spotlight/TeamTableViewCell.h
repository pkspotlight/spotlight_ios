//
//  TeamTableViewCell.h
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Team;
@class TeamTableViewCell;

@protocol TeamTableViewCellDelegate <NSObject>

- (void)followButtonPressed:(TeamTableViewCell*)teamCell completion:(void (^)(void))completion;
- (void)unfollowButtonPressed:(TeamTableViewCell*)teamCell completion:(void (^)(void))completion;

@end

@interface TeamTableViewCell : UITableViewCell

- (void)formatForTeam:(Team*)team isFollowing:(BOOL)isFollowing;

@property (readonly, nonatomic) Team* team;
@property (weak, nonatomic) id<TeamTableViewCellDelegate> delegate;

@end
