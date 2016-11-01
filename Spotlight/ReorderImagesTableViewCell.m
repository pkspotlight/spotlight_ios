//
//  ReorderImagesTableViewCell.m
//  Spotlight
//
//  Created by Aakash Gupta on 8/2/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import "ReorderImagesTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation ReorderImagesTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setDataSpotlight:(SpotlightMedia *)media{
    self.imageTitle.text = media.title;
    [self.spotlightPicImageView cancelImageRequestOperation];
    [self.spotlightPicImageView setImage:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:media.thumbnailImageFile.url]];
    [self.spotlightPicImageView
     setImageWithURLRequest:request
     placeholderImage:[UIImage imageNamed:@"spotlight_logo"]
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
         [self.spotlightPicImageView setImage:image];
         NSLog(@"got the thumbnail ");
         
     } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
         NSLog(@"fuck thumbnail failure");
     }];
    
}

@end
