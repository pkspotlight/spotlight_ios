//
//  PendingRequestTableViewCell.m
//  Spotlight
//
//  Created by Aakash Gupta on 7/22/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import "PendingRequestTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
@implementation PendingRequestTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.acceptButton.layer.cornerRadius = 10; // this value vary as per your desire
    self.acceptButton.clipsToBounds = YES;
    self.rejectButton.layer.cornerRadius = 10;
    self.rejectButton.clipsToBounds = YES;
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setData:(NSString*)name teamName:(NSString*)teamName fromUser:(User *)user forChild:(Child *)child{
    [self.profilePic.layer setCornerRadius:self.profilePic.bounds.size.width/2];
    [self.profilePic setClipsToBounds:YES];
    NSString *requestText;
    if([name isKindOfClass:[NSNull class]]){
        requestText =   [NSString stringWithFormat:@"This wants to follow %@",teamName];
    }else{
        requestText =   [NSString stringWithFormat:@"%@ wants to follow %@",name,teamName];
    }
 
    
    self.requestName.text = requestText;
    self.profilePic.image = [UIImage imageNamed:@"unknown_user"];
    
    if(user)
    {
    [user fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        [user.profilePic fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            
            if(!error)
            {
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:user.profilePic.thumbnailImageFile.url]];
                [self.profilePic
                 setImageWithURLRequest:request
                 placeholderImage:nil
                 success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                     [self.profilePic setImage:image];
                 } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                     NSLog(@"fuck thumbnail failure");
                 }];
                
            }
            
        }];
        
        
    }];
    }
    else
    {
        [child fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            
            [child.profilePic fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                
                if(!error)
                {
                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:child.profilePic.thumbnailImageFile.url]];
                    [self.profilePic
                     setImageWithURLRequest:request
                     placeholderImage:nil
                     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                         [self.profilePic setImage:image];
                     } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                         NSLog(@"fuck thumbnail failure");
                     }];
                    
                }
                
            }];
            
            
        }];
    }
   

    
}
@end
