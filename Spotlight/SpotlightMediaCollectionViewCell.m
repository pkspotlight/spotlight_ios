//
//  SpotlightMediaCollectionViewCell.m
//  Spotlight
//
//  Created by Peter Kamm on 11/20/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "SpotlightMediaCollectionViewCell.h"
#import "SpotlightMedia.h"

#import <AFNetworking/UIImageView+AFNetworking.h>


@interface SpotlightMediaCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *mediaImageView;

@end

@implementation SpotlightMediaCollectionViewCell

- (void)formatCellForSpotlightMedia:(SpotlightMedia*)media {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    [self.mediaImageView cancelImageRequestOperation];
    [self.mediaImageView setImage:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:media.thumbnailImageFile.url]];
    [self.mediaImageView
     setImageWithURLRequest:request
     placeholderImage:[UIImage imageNamed:@"spotlight_logo"]
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
         [self.mediaImageView setImage:image];
         NSLog(@"got the thumbnail ");

     } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
         NSLog(@"fuck thumbnail failure");
     }];
    
    
}

@end
