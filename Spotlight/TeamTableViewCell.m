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
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIImageView *teamImageView;
@property (weak, nonatomic) IBOutlet UILabel *seasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *sportLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *followingActivityIndicator;
@property (assign, nonatomic) BOOL isFollowing;

@end

@implementation TeamTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)formatForTeam:(Team*)team isFollowing:(BOOL)isFollowing {
    _isFollowing = isFollowing;
    [self.teamImageView.layer setCornerRadius:self.teamImageView.bounds.size.width/2];
    [self.teamImageView setClipsToBounds:YES];
    
    [self.teamNameLabel setText:[NSString stringWithFormat:@"%@ %@", team.town, team.teamName]];
    
    NSString* subtext = [NSString stringWithFormat:@"GRADE %@ - %@", team.grade, team.sport];
    [self.sportLabel setText:[subtext uppercaseString]];
    
    [self.seasonLabel setText:[[NSString stringWithFormat:@"%@ %@",team.season, team.year] uppercaseString]];
    [self formatButtonText];
    _team = team;
    [self.teamImageView cancelImageRequestOperation];
    [self.teamImageView setImage:nil];
    [team.teamLogoMedia fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:team.teamLogoMedia.thumbnailImageFile.url]];
        [self.teamImageView
         setImageWithURLRequest:request
         placeholderImage:nil
         success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
             [self.teamImageView setImage:image];
         } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
             NSLog(@"fuck thumbnail failure");
         }];
    }];
}

- (void)formatButtonText {
  
    NSString* buttonText = (_isFollowing) ? @"Following" : @"Follow";
    [self.followButton setTitle:buttonText
                       forState:UIControlStateNormal];
}




- (IBAction)followButtonPressed:(id)sender {
    
    [self.followButton setTitle:@""
                       forState:UIControlStateNormal];
    if (_isFollowing) {
        [self.delegate
         unfollowButtonPressed:self
         completion:^(void){
             self.isFollowing = NO;
             //[self formatButtonText];
         }];
    } else {
        [self.delegate
         followButtonPressed:self
         completion:^(void){
             self.isFollowing = YES;
            // [self formatButtonText];
         }];
    }
    
    //
    //    [self.followingActivityIndicator startAnimating];
    //    PFUser* user = [PFUser currentUser];
    //    PFRelation *participantRelation = [self.team relationForKey:@"teamParticipants"];
    //    if (_isFollowing) {
    //
    //        [User currentUser] fol
    //
    //
    //        [participantRelation removeObject:user];
    //    } else {
    //        [participantRelation addObject:user];
    //    }
//    
//    
//    
//    [self.team saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//        if (succeeded) {
//            self.isFollowing = !self.isFollowing;
//        }
//        [self formatButtonText];
//        [self.followingActivityIndicator stopAnimating];
////        [self.delegate performSelector:@selector(reloadTable)];
//        [self.delegate performSelector:@selector(followButtonPressed:)
//                            withObject:self];
//    }];
}

@end
