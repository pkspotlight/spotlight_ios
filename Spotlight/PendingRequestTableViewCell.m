//
//  PendingRequestTableViewCell.m
//  Spotlight
//
//  Created by Pete Kamm on 1/19/17.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import "PendingRequestTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "TeamRequest.h"

@implementation PendingRequestTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.acceptButton.layer.cornerRadius = 10; // this value vary as per your desire
    self.acceptButton.clipsToBounds = YES;
    self.rejectButton.layer.cornerRadius = 10;
    self.rejectButton.clipsToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)populatePendingInfoWithTeamRequest:(TeamRequest*)request{
    [self.profilePic.layer setCornerRadius:self.profilePic.bounds.size.width/2];
    [self.profilePic setClipsToBounds:YES];
    
    switch ([request.type intValue]) {
        case 0:
            NSLog(@"Da fuq?");
            break;
        case 1:
            [self userRequestToFollowTeam:request];
            break;
        case 2:
            [self userRequestToFollowCurrentUser:request];
            break;
        case 3:
            [self otherUserInvitedCurrentUserToFollowTeam:request];
            break;
            
        default:
            break;
    }
    
}

- (void)userRequestToFollowCurrentUser:(TeamRequest*)request {
    User* user = request.user;
    NSString *requestText = [NSString stringWithFormat:@"%@ wants to be your friend ", [user displayName]];
    self.requestName.text = requestText;
    self.profilePic.image = [UIImage imageNamed:@"unknown_user"];
    [user fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [user.profilePic fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if(!error) {
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

- (void)otherUserInvitedCurrentUserToFollowTeam:(TeamRequest*)request {
    User* requester = request.user;
    NSString *requestText = [NSString stringWithFormat:@"%@ has invited you to follow %@", [requester displayName], request.teamName];
    self.requestName.text = requestText;
    self.profilePic.image = [UIImage imageNamed:@"unknown_user"];
    
    if(!request.child) {
        [request.user fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            
            [request.user.profilePic fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                
                if(!error) {
                    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:request.user.profilePic.thumbnailImageFile.url]];
                    [self.profilePic
                     setImageWithURLRequest:urlRequest
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


- (void)userRequestToFollowTeam:(TeamRequest*)request {
    
    User* user = request.user;
    Child* child = request.child;
    NSString *requestText = [NSString stringWithFormat:@"%@ wants to follow %@ ", [user displayName], request.teamName];
    self.requestName.text = requestText;
    self.profilePic.image = [UIImage imageNamed:@"unknown_user"];
    if(request.isChild){
        [child fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            [child.profilePic fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                if(!error){
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
    } else {
        [user fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            [user.profilePic fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                if(!error){
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

@end
