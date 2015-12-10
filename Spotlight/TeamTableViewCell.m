//
//  TeamTableViewCell.m
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "TeamTableViewCell.h"
#import "Team.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface TeamTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIImageView *teamImageView;
@property (weak, nonatomic) IBOutlet UILabel *seasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *sportLabel;

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
    
    [self.teamImageView.layer setCornerRadius:self.teamImageView.bounds.size.width/2];
    [self.teamImageView setClipsToBounds:YES];
    
    [self.teamNameLabel setText:[NSString stringWithFormat:@"%@ %@", team.town, team.teamName]];
    
    NSString* subtext = [NSString stringWithFormat:@"GRADE %@ - %@", team.grade, team.sport];
    [self.sportLabel setText:[subtext uppercaseString]];
    
    [self.seasonLabel setText:[[NSString stringWithFormat:@"%@ %@",team.season, team.year] uppercaseString]];
    
    NSString* buttonText = (isFollowing) ? @"Following" : @"Follow";
    [self.followButton setTitle:buttonText
                       forState:UIControlStateNormal];
    _team = team;
    
    [self.teamImageView cancelImageRequestOperation];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:team.teamLogoMedia.thumbnailImageFile.url]];
    [self.teamImageView
     setImageWithURLRequest:request
     placeholderImage:nil
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
         [self.teamImageView setImage:image];
     } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
         NSLog(@"fuck thumbnail failure");
     }];
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
