//
//  PendingRequestTableViewCell.h
//  Spotlight
//
//  Created by Aakash Gupta on 7/22/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfilePictureMedia.h"
#import "User.h"
#import "Child.h"

@class TeamRequest;

@interface PendingRequestTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *requestName;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UIButton *rejectButton;

- (void)populatePendingInfoWithTeamRequest:(TeamRequest*)request;

@end
