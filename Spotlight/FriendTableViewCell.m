//
//  FriendTableViewCell.m
//  Spotlight
//
//  Created by Peter Kamm on 12/1/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "FriendTableViewCell.h"
#import "User.h"
#import "ProfilePictureMedia.h"

#import <Parse.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface FriendTableViewCell()

@property (strong, nonatomic) User *user;

@property (weak, nonatomic) IBOutlet UILabel *userDisplayNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (assign, nonatomic) BOOL isFollowing;

@end

@implementation FriendTableViewCell

- (void)formatForUser:(User*)user isFollowing:(BOOL)isFollowing {
    _user = user;

    [self.userImageView.layer setCornerRadius:self.userImageView.bounds.size.width/2];
    [self.userImageView setClipsToBounds:YES];
    [self.userDisplayNameLabel setText:[self.user displayName]];
    
    NSString* buttonText = (isFollowing) ? @"Following" : @"Follow";
    [self.followButton setTitle:buttonText
                       forState:UIControlStateNormal];
    
    [self.userImageView cancelImageRequestOperation];
   // [user.profilePic fetchIfNeeded];
    
    [user.profilePic fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(!error)
        {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:user.profilePic.thumbnailImageFile.url]];
            [self.userImageView
             setImageWithURLRequest:request
             placeholderImage:nil
             success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                 [self.userImageView setImage:image];
             } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                 NSLog(@"fuck thumbnail failure");
             }];
            
        }
    }];
    
    
   
}

- (void)formatButtonText {
    NSString* buttonText = (_isFollowing) ? @"Following" : @"Follow";
    [self.followButton setTitle:buttonText
                       forState:UIControlStateNormal];
}

- (IBAction)followButtonPressed:(id)sender {
//    [self.followingActivityIndicator startAnimating];
    
    PFRelation *friendRelation = [[User currentUser] relationForKey:@"friends"];
    _isFollowing ? [friendRelation removeObject:self.user] :
                   [friendRelation addObject:self.user];

    [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            self.isFollowing = !self.isFollowing;
        }
        [self formatButtonText];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Frdfollowunfollow" object:nil];
//        [self.followingActivityIndicator stopAnimating];
//        [self.delegate performSelector:@selector(reloadTable)];
    }];
}


@end
