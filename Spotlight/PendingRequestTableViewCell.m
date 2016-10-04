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
- (void)setData:(NSString*)name teamName:(NSString*)teamName fromUser:(User *)user forChild:(Child *)child isChild:(BOOL)isChild withType:(NSNumber*)type{
    [self.profilePic.layer setCornerRadius:self.profilePic.bounds.size.width/2];
    [self.profilePic setClipsToBounds:YES];
    NSString *requestText;
   
    if(name != nil ){
        
        if( [name isEqualToString:@"(null) (null)"]){
            NSString  *str =  [[name stringByReplacingOccurrencesOfString:@"(null) (null)"
                                                               withString:@"This"] mutableCopy];
            
            requestText =   [NSString stringWithFormat:@"%@ wants to follow %@",str,teamName];
        }
        
        else if([name isEqualToString:@" "]){
         
            
            requestText =   [NSString stringWithFormat:@"This wants to follow %@",teamName];

        }
        
        else{
            NSString  *str =  [[name stringByReplacingOccurrencesOfString:@"(null)"
                                                               withString:@""] mutableCopy];

            requestText =   [NSString stringWithFormat:@"%@ wants to follow %@",str,teamName];
        }
     
    }
 
    if([type intValue]==1){
        self.requestName.text = requestText;
        self.profilePic.image = [UIImage imageNamed:@"unknown_user"];
        
        if(!isChild)
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
    
    else  if([type intValue]==2){
        if(name != nil ){
            
            if( [name isEqualToString:@"(null) (null)"]){
                NSString  *str =  [[name stringByReplacingOccurrencesOfString:@"(null) (null)"
                                                                   withString:@"This"] mutableCopy];
                
                requestText =   [NSString stringWithFormat:@"%@ wants to be your friend ",str];
            }
            
            else if([name isEqualToString:@" "]){
                
                
                requestText =   [NSString stringWithFormat:@"This wants to be your friend"];
                
            }
            
            else{
                NSString  *str =  [[name stringByReplacingOccurrencesOfString:@"(null)"
                                                                   withString:@""] mutableCopy];
                
                requestText =   [NSString stringWithFormat:@"%@ wants to be your friend",str];
            }
            
        }

      
        self.requestName.text = requestText;
        self.profilePic.image = [UIImage imageNamed:@"unknown_user"];
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
    
   else if([type intValue]==3){
       
       if(name != nil ){
           
           if( [name isEqualToString:@"(null) (null)"]){
               NSString  *str =  [[name stringByReplacingOccurrencesOfString:@"(null) (null)"
                                                                  withString:@"This"] mutableCopy];
               
               requestText =   [NSString stringWithFormat:@"%@ has invited you to follow  %@",str,teamName];
           }
           
           else if([name isEqualToString:@" "]){
               
               
               requestText =   [NSString stringWithFormat:@"This has invited you to follow %@",teamName];
               
           }
           
           else{
               NSString  *str =  [[name stringByReplacingOccurrencesOfString:@"(null)"
                                                                  withString:@""] mutableCopy];
               
               requestText =   [NSString stringWithFormat:@"%@ has invited you to follow %@",str,teamName];
           }
           
       }

        self.requestName.text = requestText;
        self.profilePic.image = [UIImage imageNamed:@"unknown_user"];
        
        if(!isChild)
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
       
        
        
    }

    
}
@end
