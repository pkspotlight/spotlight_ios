//
//  FriendProfileViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 12/1/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "FriendProfileViewController.h"
#import "SpotlightFeedViewController.h"
#import "SpotlightDataSource.h"
#import "TeamsTableViewController.h"
#import "User.h"
#import "ProfilePictureMedia.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface FriendProfileViewController()

@property (weak, nonatomic) IBOutlet UIImageView *friendImageView;
@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;
@property (weak, nonatomic) IBOutlet UIView *teamsContainerView;
@property (weak, nonatomic) IBOutlet UIView *spotlightsContainerView;

@end

@implementation FriendProfileViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.friendNameLabel setText:[self.user displayName]];
    [self.friendImageView.layer setCornerRadius:self.friendImageView.bounds.size.width/2];
    [self.friendImageView.layer setBorderWidth:3];
    [self.friendImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.friendImageView setClipsToBounds:YES];
    [self.friendImageView cancelImageRequestOperation];
    [self.user.profilePic fetchIfNeeded];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.user.profilePic.thumbnailImageFile.url]];
    [self.friendImageView
     setImageWithURLRequest:request
     placeholderImage:nil
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
         [self.friendImageView setImage:image];
     } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
         NSLog(@"fuck thumbnail failure");
     }];
}
- (IBAction)segmentControllerValueChanged:(UISegmentedControl*)sender {
    if( sender.selectedSegmentIndex == 0) {
        [UIView animateWithDuration:.5
                         animations:^{
                             [self.spotlightsContainerView setAlpha:1];
                             [self.teamsContainerView setAlpha:0];
                         }];
    } else {
        [UIView animateWithDuration:.5
                         animations:^{
                             [self.teamsContainerView setAlpha:1];
                             [self.spotlightsContainerView setAlpha:0];
                         }];
    }
}

-(BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"friendTeamsEmbedSegue"]) {
        [(TeamsTableViewController*)[segue destinationViewController] setUser:self.user];
    } else {
        SpotlightDataSource* datasource = [[SpotlightDataSource alloc] initWithUser:self.user];
        [(SpotlightFeedViewController*)[segue destinationViewController] setDataSource:datasource];
    }
}

@end
