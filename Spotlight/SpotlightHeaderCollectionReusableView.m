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
@property (weak, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *spotlightDateLabel;

@end

@implementation SpotlightHeaderCollectionReusableView

- (void)formatHeaderForTeam:(Team*)team spotlight:(Spotlight*)spotlight{
    
    [self.teamImageView.layer setCornerRadius:self.teamImageView.bounds.size.width/2];
    [self.teamImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.teamImageView.layer setBorderWidth:3];
    [self.teamImageView setClipsToBounds:YES];
    
    NSDate* date = spotlight.createdAt;
    NSString* dateString = [NSDateFormatter localizedStringFromDate:date
                                                          dateStyle:NSDateFormatterLongStyle
                                                          timeStyle:NSDateFormatterNoStyle];
    [self.spotlightDateLabel setText:dateString];
    [[self teamNameLabel] setText:team.teamName];
    [team.teamLogoMedia fetchIfNeeded];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:team.teamLogoMedia.thumbnailImageFile.url]];
    [self.teamImageView cancelImageRequestOperation];
    [[self teamImageView]
     setImageWithURLRequest:request
     placeholderImage:nil
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
         [[self teamImageView] setImage:image];
     } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
         NSLog(@"fuck thumbnail failure");
     }];
}

- (IBAction)viewMontageButtonPressed:(id)sender {
    
    [self.delegate viewMontageButtonPressed:sender];
}


@end
