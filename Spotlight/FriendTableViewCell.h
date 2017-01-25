//
//  FriendTableViewCell.h
//  Spotlight
//
//  Created by Peter Kamm on 12/1/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"
@class User;

@interface FriendTableViewCell : UITableViewCell<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userDisplayNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) Team *team ;
- (void)formatForUser:(User*)user isSpectator:(BOOL)isSpectator isFollowing:(BOOL)isFollowing;
- (IBAction)followButtonPressed:(id)sender;
@end
