//
//  ChildTableViewCell.h
//  Spotlight
//
//  Created by Peter Kamm on 2/10/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"
@class Child;

@interface ChildTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userDisplayNameLabel;
@property (weak, nonatomic) Team *team ;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

//- (void)formatForChild:(Child*)child isFollowing:(BOOL)isFollowing;
- (void)formatForChild:(Child*)child isSpectator:(BOOL)isSpectator isFollowing:(BOOL)isFollowing;
@end
