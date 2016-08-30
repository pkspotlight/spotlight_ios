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
{
    BOOL doRefresh;
      NSMutableArray *pendingRequestArray;
}

@property (weak, nonatomic) IBOutlet UIImageView *teamLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (weak, nonatomic) IBOutlet UIView *teamMemberViewContainer;
@property (weak, nonatomic) IBOutlet UIView *spotlightContainer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@end

@implementation TeamDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     pendingRequestArray = [NSMutableArray new];
    doRefresh = false;
    [self fetchAllPendingRequest];

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
    if(doRefresh)
    {
        doRefresh = !doRefresh;
        if(self.spotlightContainer.subviews.count > 0)
        {
        UITableView *tableView = self.spotlightContainer.subviews[0];
            if([tableView isKindOfClass:[UITableView class]])
            {
               
                SpotlightDataSource *dataSource = (SpotlightDataSource *)[tableView dataSource];
                if([dataSource isKindOfClass:[SpotlightDataSource class]])
                [dataSource loadSpotlights:^{
                    
                }];
                
            }
        }
    }
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
        doRefresh = true;
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

-(void)fetchAllPendingRequest{
    
    PFQuery *spotlightQuery = [PFQuery queryWithClassName:@"TeamRequest"];
    [spotlightQuery whereKey:@"user" equalTo:[User currentUser]];
    
    [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(objects.count > 0)
        {
            // NSMutableArray *array = [NSMutableArray new];
            for(TeamRequest *request in objects)
            {
                if((request.requestState.intValue == reqestStatePending))
                {
                    
                    [pendingRequestArray addObject:request];
                    
                    [request.team fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                     
                        
                        
                    }];
                }
                
            }
            
            
        }
        
    }];
    
}


- (IBAction)unwindEditTeam:(UIStoryboardSegue*)sender {
    [self formatPage];
}

- (IBAction)addChildToTeamAsMember:(UIButton*)sender {
    [[[[User currentUser] children] query] findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//        NSMutableArray *filteredArrayOfObjects = [NSMutableArray new];
//        [filteredArrayOfObjects removeAllObjects];
//        for (Child *child in objects)
//        {
//            if(!([[filteredArrayOfObjects valueForKeyPath:@"objectId"] containsObject:child.objectId]))
//            {
//                [filteredArrayOfObjects addObject:child];
//            }
//        }

        [self showAlertWithChildren:objects team:self.team completion:nil];
    }];
}



- (void)showAlertWithChildren:(NSArray*)children team:(Team*)team completion:(void (^)(void))completion {
    if (children && [children count] > 0) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Which Child is on this Team?"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
            for (Child* child in children) {
            [alert addAction:[UIAlertAction actionWithTitle:[child displayName]
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        
                                                        PFQuery* moderatorQuery = [team.moderators query];
                                                        [moderatorQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                                                            if(objects.count==0){
                                                                [[[UIAlertView alloc] initWithTitle:@""
                                                                                            message:@"No admin found for this team."
                                                                                           delegate:nil
                                                                                  cancelButtonTitle:nil
                                                                                  otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
                                                            }
                                                            
                                                            else{
                                                                for (User* user in objects) {
                                                                    
                                                                    if(![self isRequestAllowed:YES withUser:nil withChild:child withTeam:team]){
                                                                        [[[UIAlertView alloc] initWithTitle:@""
                                                                                                    message:@"A request to follow this team is already sent to admin."
                                                                                                   delegate:nil
                                                                                          cancelButtonTitle:nil
                                                                                          otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
                                                                    }
                                                                    
                                                                    else{
                                                                        
                                                                        NSString *timestamp =  [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
                                                                        
                                                                        TeamRequest *teamRequest = [[TeamRequest alloc]init];
                                                                        
                                                                        [teamRequest saveTeam:team andAdmin:user  followby:[User currentUser] orChild:child withTimestamp:timestamp isChild:@1 completion:^{
                                                                            if (completion) {
                                                                                
                                                                                completion();
                                                                            }
                                                                            [pendingRequestArray addObject:teamRequest];
                                                                          //  [self.tableView reloadData];
                                                                        }];
                                                                        break;
                                                                        
                                                                    }
                                                                    
                                                                }
                                                            }
                                                        }];
                                                        
                                                        
                                                        
                                                        //                                                        [child followTeam:team completion:^{
                                                        //                                                            if (completion) {
                                                        //
                                                        //                                                                completion();
                                                        //                                                            }
                                                        //                                                        }];
                                                    }]];
        }
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
        
        
        
        
         }





-(BOOL)isRequestAllowed:(BOOL)isChild withUser:(User*)user withChild:(Child*)child withTeam:(Team*)team {
    
    if(!isChild){
        for(TeamRequest *request in pendingRequestArray){
            
            if((!request.isChild.boolValue)&&([request.team.objectId isEqualToString:team.objectId])){
                return NO;
            }
            
        }
        
        return YES;
        
    }
    else{
        for(TeamRequest *request in pendingRequestArray){
            
            if(([child.objectId isEqualToString:request.child.objectId])&&([request.team.objectId isEqualToString:team.objectId])&& (request.isChild.boolValue)){
                
                return NO;
                
                
                
            }
            
            
            
            
            
        }
        return YES;
        
    }
    
    
    
}


- (IBAction)unwindDeleteTeam:(UIStoryboardSegue*)sender {
    [self performSegueWithIdentifier:@"UnwindDeleteTeam" sender:sender];
}

-(BOOL)hidesBottomBarWhenPushed {
    return YES;
}




@end
