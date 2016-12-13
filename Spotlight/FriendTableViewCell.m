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
#import "TeamRequest.h"
#import <Parse/Parse.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface FriendTableViewCell()

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSMutableArray *pendingRequestArray;
@property (strong, nonatomic) NSMutableArray *pendingInviteRequestArray;

//@property (weak, nonatomic) IBOutlet UILabel *userDisplayNameLabel;
//@property (weak, nonatomic) IBOutlet UIButton *followButton;
//@property (weak, nonatomic) IBOutlet UIButton *currentUser;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (assign, nonatomic) BOOL isFollowing;

@end

@implementation FriendTableViewCell

-(void)awakeFromNib{
    [super awakeFromNib];

    _pendingRequestArray = [NSMutableArray new];
    _pendingInviteRequestArray = [NSMutableArray new];
    [self fetchAllPendingRequest];

    
}
- (void)formatForUser:(User*)user isSpectator:(BOOL)isSpectator isFollowing:(BOOL)isFollowing {
    _user = user;

    [self.userImageView.layer setCornerRadius:self.userImageView.bounds.size.width/2];
       [self.userImageView setClipsToBounds:YES];
    self.userImageView.layer.masksToBounds = YES;

    if(isFollowing){
           [self.userImageView.layer setBorderColor:[UIColor colorWithRed:73.0/255.0f green:160.0/255.0f blue:255.0/255.0f alpha:1.0].CGColor];
        
         [self.followButton setImage:[UIImage imageNamed:@"Following"] forState:UIControlStateNormal];
    }else{
            [self.userImageView.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.4].CGColor];
         [self.followButton setImage:[UIImage imageNamed:@"Follow"] forState:UIControlStateNormal];
    }
 
    [self.userImageView.layer setBorderWidth:2.0];
    [self.userDisplayNameLabel setText:[self.user displayName]];

//    if(isSpectator){
//        
//        if([self.team.spectatorsArray containsObject:self.user.objectId]){
//            NSLog(@"spec");
//            self.userDisplayNameLabel.textColor = [UIColor blackColor];
//            
//        }
//        else{
//           
//            self.userDisplayNameLabel.textColor = [UIColor colorWithRed:46/255.0 green:171/255.0 blue:21/255.0 alpha:1.0];
//            
//            NSLog(@"part");
//            NSString *name = [NSString stringWithFormat:@"%@ *",[self.user displayName]];
//            [self.userDisplayNameLabel setText:name];
//            
//        }
//
//    
//    }
//    else{
//        self.userDisplayNameLabel.textColor = [UIColor blackColor];
//
//        if([user.objectId isEqualToString:[User currentUser].objectId ]){
//             [self.userDisplayNameLabel setText:[NSString stringWithFormat:@"%@ (Me)",[self.user displayName]]];
//        }else{
//              [self.userDisplayNameLabel setText:[self.user displayName]];
//        }
//      
//
//    }
   
    
    self.userDisplayNameLabel.textColor = [UIColor blackColor];
    
    if([user.objectId isEqualToString:[User currentUser].objectId ]){
        [self.userDisplayNameLabel setText:[NSString stringWithFormat:@"%@ (Me)",[self.user displayName]]];
    }else{
        [self.userDisplayNameLabel setText:[self.user displayName]];
    }
    

    
        _isFollowing = isFollowing;
//    NSString* buttonText = (isFollowing) ? @"Following" : @"Follow";
//    [self.followButton setTitle:buttonText
//                       forState:UIControlStateNormal];
    
    
    
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
        if(_isFollowing){
            [self.followButton setImage:[UIImage imageNamed:@"Following"] forState:UIControlStateNormal];
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Are You Sure ?"
                                                          message:nil
                                                         delegate:self
                                                cancelButtonTitle:@"Yes"
                                                otherButtonTitles:@"No",nil];
        [message show];
           
        }
        else{
            [self.followButton setImage:[UIImage imageNamed:@"Follow"] forState:UIControlStateNormal];

    NSString *timestamp =  [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    
    TeamRequest *teamRequest = [[TeamRequest alloc]init];
    
    if(![self isRequestAllowed:NO withUser:self.user withChild:nil withTeam:nil withTag:@1]){
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:@"A request to follow this team is already sent to admin."
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
    }
    
    else{
    
    [teamRequest saveTeam:nil andAdmin:self.user  followby:[User currentUser] orChild:nil withTimestamp:timestamp isChild:nil isType:@2 completion:^{


               [_pendingRequestArray addObject:teamRequest];

    }];

    }
    
//    PFRelation *friendRelation = [[User currentUser] relationForKey:@"friends"];
//    _isFollowing ? [friendRelation removeObject:self.user] :
//                   [friendRelation addObject:self.user];
//    if(_isFollowing){
//    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Are You Sure ?"
//                                                      message:nil
//                                                     delegate:self
//                                            cancelButtonTitle:@"Yes"
//                                            otherButtonTitles:@"No",nil];
//    [message show];
//    }
//    
//    else{
//        [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//            if (succeeded) {
//                self.isFollowing = !self.isFollowing;
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"Frdfollowunfollow" object:nil];
//            }
//            [self formatButtonText];
//            
//                
//            
//            
//            //        [self.followingActivityIndicator stopAnimating];
//            //        [self.delegate performSelector:@selector(reloadTable)];
//        }];
//        
//
//    }

            
        }
    }


- (IBAction)inviteButtonPressed:(id)sender {
    NSString *timestamp =  [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    
    TeamRequest *teamRequest = [[TeamRequest alloc]init];
    
    
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Do you want to associate this user as Fan or Participant" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Fan" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if(!self.team.spectatorsArray){
            self.team.spectatorsArray = [NSMutableArray new];
        }
        [self.team.spectatorsArray addObject:self.user.objectId];
        
               
        if(![self isRequestAllowed:NO withUser:self.user withChild:nil withTeam:nil withTag:@2]){
            [[[UIAlertView alloc] initWithTitle:@""
                                        message:@"An invitation request has already been sent."
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
        }
        
        else{
            
            [teamRequest saveTeam:self.team andAdmin:self.user  followby:[User currentUser] orChild:nil withTimestamp:timestamp isChild:@0 isType:@3 completion:^{
                
                
                [_pendingInviteRequestArray addObject:teamRequest];
                
            }];
            
        }

        
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Participant" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    
        while( [self.team.spectatorsArray containsObject:self.user.objectId])
        {
            [self.team.spectatorsArray removeObject:self.user.objectId];
        }
        if(![self isRequestAllowed:NO withUser:self.user withChild:nil withTeam:nil withTag:@2]){
            [[[UIAlertView alloc] initWithTitle:@""
                                        message:@"A request to follow this team is already sent to admin."
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
        }
        
        else{
            
            [teamRequest saveTeam:self.team andAdmin:self.user  followby:[User currentUser] orChild:nil withTimestamp:timestamp isChild:@0 isType:@3 completion:^{
                
                
                [_pendingInviteRequestArray addObject:teamRequest];
                
            }];
            
        }

    
    }]];
    
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    });
    
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
                if((request.requestState.intValue == reqestStatePending) && [request.type intValue]==2)
                {
                    
                    [_pendingRequestArray addObject:request];
                    
                }
              else  if((request.requestState.intValue == reqestStatePending) && [request.type intValue]==3)
                {
                    
                    [_pendingInviteRequestArray addObject:request];
                    
                }
                
            }
            
            
        }
        else{
            //[[[self  tabBar]items] objectAtIndex:2].badgeValue  = nil;
        }
        
        //        for(TeamRequest *request in objects)
        //        {
        //            [request.admin fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        //                //   NSString *data =[NSString stringWithFormat:@"%@       %@",request.admin.firstName,request.user.firstName];
        //
        //                NSLog(@"%@",request.admin.firstName);
        //            }];
        //
        //
        //
        //        }
        
    }];
    
}



-(BOOL)isRequestAllowed:(BOOL)isChild withUser:(User*)user withChild:(Child*)child withTeam:(Team*)team withTag:(NSNumber*)tag{
    if([tag intValue]==1){
        for(TeamRequest *request in _pendingRequestArray){
            
            if(([request.admin.objectId isEqualToString:self.user.objectId])){
                return NO;
            }
            
        }
        

    }
    
    else{
        for(TeamRequest *request in _pendingInviteRequestArray){
            
            if(([request.admin.objectId isEqualToString:self.user.objectId])){
                return NO;
            }
            
        }
    }
    
    
        return YES;
    
    
    
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   
    if(buttonIndex ==0)
    {
        
        PFRelation *friendRelation = [[User currentUser] relationForKey:@"friends"];
        [friendRelation removeObject:self.user] ;

        [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                self.isFollowing = !self.isFollowing;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Frdfollowunfollow" object:nil];
               
            }
            [self formatButtonText];
            
         

            
            
        }];

        

    }
        
    
}



@end
