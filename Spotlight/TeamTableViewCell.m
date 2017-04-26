//
//  TeamTableViewCell.m
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "TeamTableViewCell.h"
#import "Team.h"
#import "User.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface TeamTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *teamNameLabel;
//@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIImageView *teamImageView;
@property (weak, nonatomic) IBOutlet UILabel *seasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *sportLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *followingActivityIndicator;
@property (assign, nonatomic) BOOL isFollowing;

@end

@implementation TeamTableViewCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)formatForTeam:(Team*)team isFollowing:(BOOL)isFollowing {
    _isFollowing = isFollowing;
    [self.teamImageView.layer setCornerRadius:self.teamImageView.bounds.size.width/2];
    [self.teamImageView setClipsToBounds:YES];
    
    [self.teamNameLabel setText:[NSString stringWithFormat:@"%@ %@", team.town, team.teamName]];
        
    if (team.grade) {
        NSString* subtext = [NSString stringWithFormat:@"GRADE %@ - %@", team.grade, team.sport];
        [self.sportLabel setText:[subtext uppercaseString]];
    } else {
        [self.sportLabel setText:[team.sport uppercaseString]];
    }
    
    [self.seasonLabel setText:[[NSString stringWithFormat:@"%@ %@",team.season, team.year] uppercaseString]];
    
    if(isFollowing){
        [self.teamImageView.layer setBorderColor:[UIColor colorWithRed:73.0/255.0f green:160.0/255.0f blue:255.0/255.0f alpha:1.0].CGColor];
        
        [self.followButton setImage:[UIImage imageNamed:@"Following"] forState:UIControlStateNormal];
    }else{
        [self.teamImageView.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.4].CGColor];
        [self.followButton setImage:[UIImage imageNamed:@"Follow"] forState:UIControlStateNormal];
    }
    [self.teamImageView.layer setBorderWidth:2.0];

    
    //[self formatButtonText];
    _team = team;
    [self.teamImageView cancelImageRequestOperation];
    [self.teamImageView setImage:nil];
    [self.teamImageView setImage:[UIImage imageNamed:@"UserPlaceholder"]];

    [team.teamLogoMedia fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {

        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:team.teamLogoMedia.thumbnailImageFile.url]];
        [self.teamImageView
         setImageWithURLRequest:request
         placeholderImage:[UIImage imageNamed:@"UserPlaceholder"]
         success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
           
             [self.teamImageView setImage:image];
         } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
             NSLog(@"fuck thumbnail failure");
         }];
    }];
}

- (void)formatButtonText {
  
    if(_isFollowing){
        [self.teamImageView.layer setBorderColor:[UIColor colorWithRed:73.0/255.0f green:160.0/255.0f blue:255.0/255.0f alpha:1.0].CGColor];
        
        [self.followButton setImage:[UIImage imageNamed:@"Following"] forState:UIControlStateNormal];
    }else{
        [self.teamImageView.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.4].CGColor];
        [self.followButton setImage:[UIImage imageNamed:@"Follow"] forState:UIControlStateNormal];
    }

    [self.teamImageView.layer setBorderWidth:2.0];

}

- (IBAction)followButtonPressed:(id)sender {
    if (_isFollowing) {
        
        [self.delegate
         unfollowButtonPressed:self
         completion:^(void){
             self.isFollowing = NO;
//             [self.followButton setTitle:@"Following"
//                                forState:UIControlStateNormal];

             [self formatButtonText];
         }];
    } else {
        
       
        [self.delegate
         followButtonPressed:self
         completion:^(void){
//             [self.followButton setTitle:@""
//                                forState:UIControlStateNormal];
             self.isFollowing = YES;
            [self formatButtonText];
         }];
    }
}

@end
