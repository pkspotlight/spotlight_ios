//
//  SpotlightTableViewCell.m
//  Spotlight
//
//  Created by Peter Kamm on 10/19/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "SpotlightTableViewCell.h"
#import "Team.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface SpotlightTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UILabel *createdByLabel;
@property (weak, nonatomic) IBOutlet UIImageView *teamImageView;

@end

@implementation SpotlightTableViewCell



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)formatForSpotlight:(Spotlight*)spotlight {
    
    [self.mainImageView setImage:nil];
    [self.mainImageView cancelImageRequestOperation];
    [self.titleLabel setText:spotlight.team.teamName];
    [self.createdByLabel setText:[NSString stringWithFormat:@"by %@", spotlight.creatorName]];
    [spotlight allThumbnailUrls:^(NSArray *urls, NSError *error) {
        if (urls && !error) {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[urls firstObject]]];
            [self.mainImageView
             setImageWithURLRequest:request
             placeholderImage:nil
             success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                 [self.mainImageView setImage:image];
             } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                 NSLog(@"fuck thumbnail failure");
             }];
        }
    }];
    
    [self.teamImageView.layer setCornerRadius:self.teamImageView.bounds.size.width/2];
    [self.teamImageView.layer setBorderWidth:3];
    [self.teamImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.teamImageView setClipsToBounds:YES];
    [self.teamImageView cancelImageRequestOperation];

    [spotlight.team.teamLogoMedia fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[(TeamLogoMedia*)object thumbnailImageFile].url]];
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

@end
