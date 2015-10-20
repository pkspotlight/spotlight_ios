//
//  SpotlightMediaTableViewCell.m
//  Spotlight
//
//  Created by Peter Kamm on 10/20/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "SpotlightMediaTableViewCell.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface SpotlightMediaTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *mediaImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation SpotlightMediaTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)formatWithSpotlightMedia:(SpotlightMedia*)spotlightMedia {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    [self.dateLabel setText:[dateFormatter stringFromDate:spotlightMedia.createdAt]];
    [self.mediaImageView cancelImageRequestOperation];
    [self.mediaImageView setImage:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:spotlightMedia.thumbnailImageFile.url]];
    [self.mediaImageView
     setImageWithURLRequest:request
     placeholderImage:nil
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
         [self.mediaImageView setImage:image];
     } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
         NSLog(@"fuck thumbnail failure");
     }];
    
}

@end
