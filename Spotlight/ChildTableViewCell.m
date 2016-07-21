//
//  ChildTableViewCell.m
//  Spotlight
//
//  Created by Peter Kamm on 2/10/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import "ChildTableViewCell.h"
#import "ProfilePictureMedia.h"
#import "Child.h"

#import <Parse.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface ChildTableViewCell()

@property (strong, nonatomic) Child *child;

@property (weak, nonatomic) IBOutlet UILabel *userDisplayNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (assign, nonatomic) BOOL isFollowing;

@end

@implementation ChildTableViewCell

- (void)formatForChild:(Child*)child isFollowing:(BOOL)isFollowing {
    _child = child;
    
    [self.userImageView.layer setCornerRadius:self.userImageView.bounds.size.width/2];
    [self.userImageView setClipsToBounds:YES];
    [self.userDisplayNameLabel setText:[self.child displayName]];
    
    NSString* buttonText = (isFollowing) ? @"Following" : @"Follow";
    [self.followButton setTitle:buttonText
                       forState:UIControlStateNormal];
    
    [self.userImageView cancelImageRequestOperation];
    [child.profilePic fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(!error)
        {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:child.profilePic.thumbnailImageFile.url]];
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
//    NSString* buttonText = (_isFollowing) ? @"Following" : @"Follow";
//    [self.followButton setTitle:buttonText
//                       forState:UIControlStateNormal];
    [self.followButton setHidden:YES];
}

//- (IBAction)followButtonPressed:(id)sender {
//    //    [self.followingActivityIndicator startAnimating];
//    
//    PFRelation *friendRelation = [[User currentUser] relationForKey:@"friends"];
//    _isFollowing ? [friendRelation removeObject:self.user] :
//    [friendRelation addObject:self.user];
//    
//    [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//        if (succeeded) {
//            self.isFollowing = !self.isFollowing;
//        }
//        [self formatButtonText];
//        //        [self.followingActivityIndicator stopAnimating];
//        //        [self.delegate performSelector:@selector(reloadTable)];
//    }];
//}


@end
