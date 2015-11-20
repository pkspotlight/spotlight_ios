//
//  TeamTableViewCell.m
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "TeamTableViewCell.h"
#import "Team.h"

@interface TeamTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIImageView *teamImageView;

@end

@implementation TeamTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)formatForTeam:(Team*)team isFollowing:(BOOL)isFollowing {
    
    [self.teamNameLabel setText:team.teamName];
    
    NSString* buttonText = (isFollowing) ? @"Following" : @"Follow";
    [self.followButton setTitle:buttonText
                       forState:UIControlStateNormal];
    _team = team;
}

- (IBAction)followButtonPressed:(id)sender {
    PFUser* user = [PFUser currentUser];
    PFRelation *participantRelation = [self.team relationForKey:@"teamParticipants"];
    [participantRelation addObject:user];
    [self.team saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.followButton setTitle:@"Following"
                           forState:UIControlStateNormal];
    }];
}

@end
