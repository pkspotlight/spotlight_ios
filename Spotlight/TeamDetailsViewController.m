//
//  TeamDetailsViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 12/8/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "TeamDetailsViewController.h"
#import "SpotlightFeedViewController.h"
#import "SpotlightMedia.h"
#import "Team.h"
#import "User.h"
#import "FriendsTableViewController.h"
#import "CreateTeamTableViewController.h"
#import "SpotlightDataSource.h"
#import "CreateSpotlightTableViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface TeamDetailsViewController()

@property (weak, nonatomic) IBOutlet UIImageView *teamLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (weak, nonatomic) IBOutlet UIView *teamMemberViewContainer;
@property (weak, nonatomic) IBOutlet UIView *spotlightContainer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@end

@implementation TeamDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.teamLogoImageView.layer setCornerRadius:self.teamLogoImageView.bounds.size.width/2];
    [self.teamLogoImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.teamLogoImageView.layer setBorderWidth:3];
    [self.teamLogoImageView setClipsToBounds:YES];
    [self formatPage];

    PFQuery* moderatorQuery = [self.team.moderators query];
    [moderatorQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        for (User* user in objects) {
            if ([user.objectId isEqualToString:[[User currentUser] objectId]]) {
                [self.editButton setTintColor:[UIColor whiteColor]];
                [self.editButton setEnabled:YES];
            }
        }
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    
}
- (IBAction)teamSegmentControllerValueChanged:(UISegmentedControl*)sender {
    if( sender.selectedSegmentIndex == 0) {
        [UIView animateWithDuration:.5
                         animations:^{
                             [self.spotlightContainer setAlpha:1];
                             [self.teamMemberViewContainer setAlpha:0];
                         }];
    } else {
        [UIView animateWithDuration:.5
                         animations:^{
                             [self.teamMemberViewContainer setAlpha:1];
                             [self.spotlightContainer setAlpha:0];
                         }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"teamMemberEmbedSegue"]) {
        [(FriendsTableViewController*)[segue destinationViewController] setTeam:self.team];
    } else if ([segue.identifier isEqualToString:@"EditTeamSegue"]){
        [(CreateTeamTableViewController*)[(UINavigationController*)[segue destinationViewController] viewControllers][0] setTeam:self.team];
    } else if ([segue.identifier isEqualToString:@"EmbedSpotlightDataSource"]){
        SpotlightDataSource* datasource = [[SpotlightDataSource alloc] initWithTeam:self.team];
        [(SpotlightFeedViewController*)[segue destinationViewController] setDataSource:datasource];
    }
    else if ([segue.identifier isEqualToString:@"createSpotLightFromTeamDetail"]) {
            
            CreateSpotlightTableViewController* vc = (CreateSpotlightTableViewController*)[segue destinationViewController];
        vc.isFromTeamdetail = YES;
            [vc setTeam:_team];
        }
}

- (void)formatPage {
    [self.teamNameLabel setText:self.team.teamName];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.team.teamLogoMedia.thumbnailImageFile.url]];
    [self.teamLogoImageView
     setImageWithURLRequest:request
     placeholderImage:nil
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
         [self.teamLogoImageView setImage:image];
     } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
         NSLog(@"fuck thumbnail failure");
     }];

}

- (IBAction)unwindEditTeam:(UIStoryboardSegue*)sender {
    [self formatPage];
}

- (IBAction)unwindDeleteTeam:(UIStoryboardSegue*)sender {
    [self performSegueWithIdentifier:@"UnwindDeleteTeam" sender:sender];
}

-(BOOL)hidesBottomBarWhenPushed {
    return YES;
}




@end
