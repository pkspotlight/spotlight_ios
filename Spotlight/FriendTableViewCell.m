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
#import <Parse.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface FriendTableViewCell()

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSMutableArray *pendingRequestArray;;


//@property (weak, nonatomic) IBOutlet UILabel *userDisplayNameLabel;
//@property (weak, nonatomic) IBOutlet UIButton *followButton;
//@property (weak, nonatomic) IBOutlet UIButton *currentUser;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (assign, nonatomic) BOOL isFollowing;

@end

@implementation FriendTableViewCell

-(void)awakeFromNib{
    _pendingRequestArray = [NSMutableArray new];
    [self fetchAllPendingRequest];

    
}
- (void)formatForUser:(User*)user isFollowing:(BOOL)isFollowing {
    _user = user;

    [self.userImageView.layer setCornerRadius:self.userImageView.bounds.size.width/2];
    [self.userImageView setClipsToBounds:YES];
    [self.userDisplayNameLabel setText:[self.user displayName]];
    _isFollowing = isFollowing;
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
        if(_isFollowing){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Are You Sure ?"
                                                          message:nil
                                                         delegate:self
                                                cancelButtonTitle:@"Yes"
                                                otherButtonTitles:@"No",nil];
        [message show];
           
        }
        else{
    
    NSString *timestamp =  [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    
    TeamRequest *teamRequest = [[TeamRequest alloc]init];
    
    if(![self isRequestAllowed:NO withUser:self.user withChild:nil withTeam:nil]){
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



-(BOOL)isRequestAllowed:(BOOL)isChild withUser:(User*)user withChild:(Child*)child withTeam:(Team*)team {
    
    
        for(TeamRequest *request in _pendingRequestArray){
            
            if(([request.admin.objectId isEqualToString:self.user.objectId])){
                return NO;
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
