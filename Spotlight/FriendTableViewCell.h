//
//  FriendTableViewCell.h
//  Spotlight
//
//  Created by Peter Kamm on 12/1/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface FriendTableViewCell : UITableViewCell<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userDisplayNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

- (void)formatForUser:(User*)user isFollowing:(BOOL)isFollowing;

@end
