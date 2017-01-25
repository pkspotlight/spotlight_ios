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
    [super awakeFromNib];
    self.acceptButton.layer.cornerRadius = 10;
    self.acceptButton.clipsToBounds = YES;
    self.rejectButton.layer.cornerRadius = 10;
    self.rejectButton.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)populatePendingInfoWithTeamRequest:(TeamRequest*)request{
    [self.profilePic.layer setCornerRadius:self.profilePic.bounds.size.width/2];
    [self.profilePic setClipsToBounds:YES];
    self.profilePic.image = [UIImage imageNamed:@"unknown_user"];
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
    if (request.isChild) {
        [request.child fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            NSString *requestText = [NSString stringWithFormat:@"%@ wants to follow you.", [request.child displayName]];
            [self populatePictureForChild:request.child withText:requestText];
        }];
    } else {
        [request.user fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            NSString *requestText = [NSString stringWithFormat:@"%@ wants to follow you.", [request.user displayName]];
            [self populatePictureForUser:request.user withText:requestText];
        }];
    }
}

- (void)otherUserInvitedCurrentUserToFollowTeam:(TeamRequest*)request {
    if (request.isChild) {
        [request.child fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            NSString *requestText = [NSString stringWithFormat:@"%@ has invited you to follow %@", [request.child displayName], request.teamName];
            [self populatePictureForChild:request.child withText:requestText];
        }];
    } else {
        [request.user fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            NSString *requestText = [NSString stringWithFormat:@"%@ has invited you to follow %@", [request.user displayName], request.teamName];
            [self populatePictureForUser:request.user withText:requestText];
        }];
    }
}

- (void)userRequestToFollowTeam:(TeamRequest*)request {
    if (request.isChild) {
        [request.child fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            NSString *requestText = [NSString stringWithFormat:@"%@ wants to follow %@ ", [request.child displayName], request.teamName];
            [self populatePictureForChild:request.child withText:requestText];
        }];
    } else {
        [request.user fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            NSString *requestText = [NSString stringWithFormat:@"%@ wants to follow %@ ", [request.user displayName], request.teamName];
            [self populatePictureForUser:request.user withText:requestText];
        }];
    }
}

- (void)populatePictureForChild:(Child*)child withText:(NSString*)requestText{
    self.requestName.text = requestText;
    [child.profilePic fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(!error){
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:child.profilePic.thumbnailImageFile.url]];
            [self.profilePic
             setImageWithURLRequest:request
             placeholderImage:[UIImage imageNamed:@"unknown_user"]
             success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                 [self.profilePic setImage:image];
             } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                 NSLog(@"fuck thumbnail failure");
             }];
        }
    }];
}

- (void)populatePictureForUser:(User*)user withText:(NSString*)requestText{
    self.requestName.text = requestText;
    [user.profilePic fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(!error){
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:user.profilePic.thumbnailImageFile.url]];
            [self.profilePic
             setImageWithURLRequest:request
             placeholderImage:[UIImage imageNamed:@"unknown_user"]
             success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                 [self.profilePic setImage:image];
             } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                 NSLog(@"fuck thumbnail failure");
             }];
        }
    }];
}

@end
