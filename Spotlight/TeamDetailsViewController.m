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
#import "FriendFinderTableViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface TeamDetailsViewController()
{
    BOOL doRefresh;
    NSMutableArray *pendingRequestArray;
    BOOL isUserFollowCurrentTeam;
    BOOL isUserTeamAdmin;
}

@property (weak, nonatomic) IBOutlet UIImageView *teamLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *teamLogoImageViewFront;

@property (weak, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (weak, nonatomic) IBOutlet UIView *teamMemberViewContainer;
@property (weak, nonatomic) IBOutlet UIView *spotlightContainer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) IBOutlet UIButton *spotlightButton;

@property (weak, nonatomic) IBOutlet UIButton *teamMemberButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;



@end

@implementation TeamDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pendingRequestArray = [NSMutableArray new];
    
    doRefresh = false;
    [self fetchAllPendingRequest];
    
    [self checkUserFollowCurrentTeam];
    [self checkUserFollowCurrentTeam];
    [self.teamLogoImageViewFront.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.4].CGColor];
    [self.teamLogoImageViewFront.layer setCornerRadius:5];
    [self.teamLogoImageViewFront.layer setBorderWidth:3];
    _spotlightButton.selected = YES;
    
    [_teamLogoImageViewFront setClipsToBounds:YES];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"BackImage"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked:)];
    
    
    self.navigationItem.leftBarButtonItem = barButton;
    
    
    [self formatPage];
    
    PFQuery* moderatorQuery = [self.team.moderators query];
    [moderatorQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        for (User* user in objects) {
            if ([user.objectId isEqualToString:[[User currentUser] objectId]]) {
                [self.editButton setTintColor:[UIColor whiteColor]];
                [self.editButton setEnabled:YES];
                [self.inviteButton setHidden:NO];
                isUserTeamAdmin = YES;
            }
            
        }
    }];
}



-(void)checkWhetherTeamBelongsToAdministrator{
    PFQuery* moderatorQuery = [self.team.moderators query];
    [moderatorQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(objects.count==0){
            [[[UIAlertView alloc] initWithTitle:@""
                                        message:@"No admin was found for this team."
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
        }
        
        else{
            for (User* user in objects) {
                if([user.objectId isEqualToString:[User currentUser].objectId]){
                    self.inviteButton.hidden = NO;
                }
                else{
                    self.inviteButton.hidden = YES;
                    
                }
            }
        }
    }];
    
}


-(void)checkUserFollowCurrentTeam{
    PFQuery *query = [[[User currentUser] teams] query];
    [query includeKey:@"teamLogoMedia"];
    [query orderByDescending:@"year"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (Team *team in objects) {
                if([team.objectId isEqualToString:self.team.objectId]){
                    isUserFollowCurrentTeam = YES;
                } else{
                    isUserFollowCurrentTeam = NO;
                }
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

//-(void)inviteButtonactive{
//    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Invite" style:UIBarButtonItemStylePlain target:self action:@selector(invite)];
//    [barButton setTitle:@"Invite"];
//    self.navigationItem.rightBarButtonItem = barButton;
//}


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

- (void)backButtonClicked:(UIBarButtonItem*)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.teamMembersArray removeAllObjects];
}

- (IBAction)spotlightClicked:(UIButton*)sender{
    _spotlightButton.selected = YES;
    _teamMemberButton.selected = NO;
    _addButton.selected = NO;
    [UIView animateWithDuration:.5
                     animations:^{
                         [self.spotlightContainer setAlpha:1];
                         [self.teamMemberViewContainer setAlpha:0];
                     }];
    
}
- (IBAction)teamMemberClicked:(UIButton*)sender{
    _spotlightButton.selected = NO;
    _teamMemberButton.selected = YES;
    _addButton.selected = NO;
    [UIView animateWithDuration:.5
                     animations:^{
                         [self.teamMemberViewContainer setAlpha:1];
                         [self.spotlightContainer setAlpha:0];
                     }];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"teamMemberEmbedSegue"]) {
        
        [(FriendsTableViewController*)[segue destinationViewController] setTeam:self.team];
        [(FriendsTableViewController*)[segue destinationViewController] setDelegate:self];
    } else if ([segue.identifier isEqualToString:@"EmbedSpotlightDataSource"]){
        SpotlightDataSource* datasource = [[SpotlightDataSource alloc] initWithTeam:self.team];
        [(SpotlightFeedViewController*)[segue destinationViewController] setDataSource:datasource];
    } else if ([segue.identifier isEqualToString:@"createSpotLightFromTeamDetail"]) {
        doRefresh = true;
        CreateSpotlightTableViewController* vc = (CreateSpotlightTableViewController*)[segue destinationViewController];
        vc.isFromTeamdetail = YES;
        [vc setTeam:_team];
    }
}


- (IBAction)editBtnClicked:(UIButton*)sender{
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CreateTeamTableViewController *createTeam = [storyboard instantiateViewControllerWithIdentifier:@"CreateTeamTableViewController"];
    createTeam.team = _team;
    createTeam.isEdit = YES;
    [self.navigationController pushViewController:createTeam animated:YES];
}

- (void)createSpotlight{
    
    doRefresh = true;
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CreateSpotlightTableViewController *createSpotlight = [storyboard instantiateViewControllerWithIdentifier:@"CreateSpotlightTableViewController"];
    createSpotlight.isFromTeamdetail = YES;
    createSpotlight.team = _team;
    [self.navigationController pushViewController:createSpotlight animated:YES];
}


- (void)formatPage {
    [self.teamNameLabel setText:self.team.teamName];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.team.teamLogoMedia.thumbnailImageFile.url]];
    [self.teamLogoImageView
     setImageWithURLRequest:request
     placeholderImage:nil
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
         [self.teamLogoImageView setImage:image];
         [self.teamLogoImageViewFront setImage:image];
     } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
         NSLog(@"fuck thumbnail failure");
     }];
    
}

-(void)getTeamMembers:(NSMutableArray *)teamMembers{
    self.teamMembersArray = teamMembers;
}

-(void)fetchAllPendingRequest{
    PFQuery *spotlightQuery = [PFQuery queryWithClassName:@"TeamRequest"];
    [spotlightQuery whereKey:@"user" equalTo:[User currentUser]];
    [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(objects.count > 0) {
            for(TeamRequest *request in objects) {
                if((request.requestState.intValue == reqestStatePending)) {
                    [pendingRequestArray addObject:request];
                    [request.team fetchIfNeededInBackgroundWithBlock:nil];
                }
            }
        }
    }];
}

- (IBAction)inviteMembersToFollowTeam:(UIButton*)sender{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FriendFinderTableViewController *friendFinderController = [storyboard instantiateViewControllerWithIdentifier:@"SearchFriends"];
    friendFinderController.selectedTeam = self.team;
    friendFinderController.controllerType = [NSNumber numberWithInt:1];
    [self.navigationController pushViewController:friendFinderController animated:YES];
    
}

- (IBAction)unwindEditTeam:(UIStoryboardSegue*)sender {
    [self formatPage];
}


- (IBAction)addChildOrSpotlight:(UIButton*)sender {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"What do you want to do?"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Create Spotlight"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self createSpotlight];
                                                
                                            }]];
    
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Add Family Member"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                                [self addChildToTeamAsMember];
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                            }]];
    
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)addChildToTeamAsMember{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:YES];
    [hud setLabelText:@"Please Wait..."];
    if(isUserTeamAdmin){
        [[[[User currentUser] children] query] findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            if(objects.count>0){
                NSMutableArray *filteredArrayOfObjects = [NSMutableArray new];
                [filteredArrayOfObjects removeAllObjects];
                for (Child *child in objects) {
                    if(!([[self.teamMembersArray valueForKeyPath:@"objectId"] containsObject:child.objectId])) {
                        [filteredArrayOfObjects addObject:child];
                    }
                }
                if(filteredArrayOfObjects.count>0){
                    [self showAlertWithChildrenAdmin:filteredArrayOfObjects team:self.team completion:nil];
                }
                else{
                    [[[UIAlertView alloc] initWithTitle:@""
                                                message:@"All children are members of this team already"
                                               delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
                }
            } else{
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:@"No child is associated with this user"
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
                
            }
            
            [hud hide:YES];
        }];
        
    }else{
        [[[[User currentUser] children] query] findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            if(objects.count>0){
                NSMutableArray *filteredArrayOfObjects = [NSMutableArray new];
                [filteredArrayOfObjects removeAllObjects];
                
                for (Child *child in objects) {
                    if(!([[self.teamMembersArray valueForKeyPath:@"objectId"] containsObject:child.objectId])) {
                        [filteredArrayOfObjects addObject:child];
                    }
                }
                [self showAlertWithChildren:filteredArrayOfObjects team:self.team completion:nil];
            }else{
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:@"No child is associated with this user"
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
            }
            [hud hide:YES];
        }];
    }
}



- (void)showAlertWithChildren:(NSArray*)children team:(Team*)team completion:(void (^)(void))completion {
    if (children && [children count] > 0) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Which Child is on this Team?"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        if(!isUserFollowCurrentTeam){
            [alert addAction:[UIAlertAction actionWithTitle:@"None, I just want to follow it"
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
                                                                    
                                                                    if(![self isRequestAllowed:YES withUser:[User currentUser] withChild:nil withTeam:team]){
                                                                        [[[UIAlertView alloc] initWithTitle:@""
                                                                                                    message:@"A request to follow this team is already sent to admin."
                                                                                                   delegate:nil
                                                                                          cancelButtonTitle:nil
                                                                                          otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
                                                                    }
                                                                    
                                                                    else{
                                                                        
                                                                        NSString *timestamp =  [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
                                                                        
                                                                        TeamRequest *teamRequest = [[TeamRequest alloc]init];
                                                                        
                                                                        [teamRequest saveTeam:team andAdmin:user  followby:[User currentUser] orChild:nil withTimestamp:timestamp isChild:@0 isType:@1 completion:^{
                                                                            if (completion) {
                                                                                
                                                                                completion();
                                                                            }
                                                                            [pendingRequestArray addObject:teamRequest];
                                                                            isUserFollowCurrentTeam = YES;
                                                                            [self.teamMembersArray addObject:[User currentUser]];
                                                                            //  [self.tableView reloadData];
                                                                        }];
                                                                        break;
                                                                        
                                                                    }
                                                                    
                                                                }
                                                            }
                                                        }];
                                                    }]];
        }
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
                                                                        
                                                                        [teamRequest saveTeam:team andAdmin:user  followby:nil orChild:child withTimestamp:timestamp isChild:@1 isType:@1 completion:^{
                                                                            if (completion) {
                                                                                [pendingRequestArray addObject:teamRequest];
                                                                                [self.teamMembersArray addObject:child];
                                                                                completion();
                                                                            }
                                                                            
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

- (void)showAlertWithChildrenAdmin:(NSArray*)children team:(Team*)team completion:(void (^)(void))completion {
    if (children && [children count] > 0) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Which Child is on this Team?"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        if(!isUserFollowCurrentTeam){
            [alert addAction:[UIAlertAction actionWithTitle:@"None, I just want to follow it"
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
                                                                    
                                                                    if(![self isRequestAllowed:YES withUser:[User currentUser] withChild:nil withTeam:team]){
                                                                        [[[UIAlertView alloc] initWithTitle:@""
                                                                                                    message:@"A request to follow this team is already sent to admin."
                                                                                                   delegate:nil
                                                                                          cancelButtonTitle:nil
                                                                                          otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
                                                                    }else{
                                                                        [[User currentUser] followTeamWithBlockCallback:team completion:^(BOOL succeeded, NSError * _Nullable error) {
                                                                            if(succeeded)
                                                                            {
                                                                                [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
                                                                                isUserFollowCurrentTeam = YES;
                                                                                [self.teamMembersArray addObject:[User currentUser]];
                                                                                
                                                                            }
                                                                        }];
                                                                        break;
                                                                    }
                                                                    
                                                                }
                                                            }
                                                        }];
                                                    }]];
        }
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
                                                                    }else{
                                                                        [child followTeamWithBlockCallback:team  completion:nil];
                                                                        [self.teamMembersArray addObject:child];
                                                                        break;
                                                                    }
                                                                }
                                                            }
                                                        }];
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
    }else{
        for(TeamRequest *request in pendingRequestArray){
            if(([child.objectId isEqualToString:request.child.objectId]) &&
               ([request.team.objectId isEqualToString:team.objectId]) &&
               (request.isChild.boolValue)){
                
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
