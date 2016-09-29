//
//  SpotlightHeaderCollectionReusableView.m
//  Spotlight
//
//  Created by Peter Kamm on 11/20/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "SpotlightHeaderCollectionReusableView.h"
#import "Team.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "Spotlight.h"

@interface SpotlightHeaderCollectionReusableView()

@property (weak, nonatomic) IBOutlet UIImageView *teamImageView;
@property (weak, nonatomic) IBOutlet UIImageView *teamUserImageView;
@property (weak, nonatomic) IBOutlet UIView *teamUserView;


@property (weak, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *teamLocationLabel;

@property (weak, nonatomic) IBOutlet UILabel *spotlightDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewMontageButton;
@property (weak, nonatomic) IBOutlet UIButton *shareMontageButton;
@property (weak, nonatomic) IBOutlet UILabel *sportLabel;
@property (weak, nonatomic) IBOutlet UIButton *reorderingSpotlightButton;

@end

@implementation SpotlightHeaderCollectionReusableView

- (void)formatHeaderForTeam:(Team*)team spotlight:(Spotlight*)spotlight{
    
    [self.teamNameLabel setText:[NSString stringWithFormat:@"%@",team.teamName]];
      [self.teamLocationLabel setText:[NSString stringWithFormat:@"Town: %@", team.town]];
    
    NSString* subtext = [NSString stringWithFormat:@"Sport/Activity: %@",team.sport];
    [self.sportLabel setText:subtext];

    
//    [self.viewMontageButton.layer setBorderColor:[UIColor whiteColor].CGColor];
//    [self.viewMontageButton.layer setBorderWidth:1];
//    [self.viewMontageButton.layer setCornerRadius:5];
//    
//    [self.reorderingSpotlightButton.layer setBorderColor:[UIColor whiteColor].CGColor];
//    [self.reorderingSpotlightButton.layer setBorderWidth:1];
//    [self.reorderingSpotlightButton.layer setCornerRadius:5];
//    
//    [self.shareMontageButton.layer setBorderColor:[UIColor whiteColor].CGColor];
//    [self.shareMontageButton.layer setBorderWidth:1];
//    [self.shareMontageButton.layer setCornerRadius:5];
//    
  
    [self.teamUserImageView.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.4].CGColor];
      [self.teamUserImageView.layer setCornerRadius:5];
    [self.teamUserImageView.layer setBorderWidth:2];
  
   [_teamUserImageView setClipsToBounds:YES];
    
    NSDate* date = spotlight.createdAt;
    
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"MMM d, yyyy"]; // Date formater
   
    
    NSString *spotlightTime = [NSString stringWithFormat:@"%@",[dateformate stringFromDate:date]];

    
//    NSString* dateString = [NSDateFormatter localizedStringFromDate:date
//                                                          dateStyle:NSDateFormatterLongStyle
//                                                          timeStyle:NSDateFormatterNoStyle];
    [self.spotlightDateLabel setText:spotlightTime];
    [team.teamLogoMedia fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:team.teamLogoMedia.thumbnailImageFile.url]];
        [self.teamImageView cancelImageRequestOperation];
        [[self teamImageView]
         setImageWithURLRequest:request
         placeholderImage:nil
         success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
             [[self teamImageView] setImage:image];
             [[self teamUserImageView] setImage:image];
         } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
             NSLog(@"fuck thumbnail failure");
         }];
    }];
    
    
    [self.teamUserView layoutIfNeeded];
   
}

- (IBAction)viewMontageButtonPressed:(id)sender {
    
    [self.delegate viewMontageButtonPressed:sender];
}


@end
