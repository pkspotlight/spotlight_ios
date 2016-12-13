//
//  MainTabBarController.m
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "MainTabBarController.h"
#import <Parse/Parse.h>
#import "User.h"
#import "Child.h"
#import "TeamRequest.h"
#import "AppDelegate.h"

#define appDel ((AppDelegate *)[UIApplication sharedApplication].delegate)

@interface MainTabBarController ()
{
    BOOL isAcceptingTeams;
}
@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showLoginPopUp];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePendingRequest) name:@"PendingRequest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePendingMessageRequest) name:@"ShowAlertForAcceptedRequest" object:nil];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)showLoginPopUp{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"SpotlightLoginPopUp"] == FALSE)
    {
        
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:@"Successfully logged in."
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
        
       
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"SpotlightLoginPopUp"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //Alert code will go here...
    }
    
}

-(void)deleteTeamRequest:(TeamRequest *)request
{
    [request deleteInBackground];
}

-(void)followAcceptedRequest:(TeamRequest *)request
{
    if([request.type intValue]==1 ||[request.type intValue]==3){
    if(!request.isChild.boolValue)
    {
        [request.team fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if(!error)
            {
            [[User currentUser] followTeamWithBlockCallback:request.team completion:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];

                    [request deleteInBackground];
                }
            }];
            }

        }];
    }
    else
    {
        
        [request.team fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
    
            [request.child fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                if(!error)
                {
                    [request.child followTeamWithBlockCallback:request.team  completion:^(BOOL succeeded, NSError * _Nullable error) {
                        if(succeeded)
                        {
                            [request deleteInBackground];
                        }
                    }];
                }
            }];
            
            
        }];
        
    }
    }
    else if([request.type intValue]==2){
        PFRelation *friendRelation = [[User currentUser] relationForKey:@"friends"];
         [friendRelation addObject:request.admin];
        [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [request deleteInBackground];

                [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Frdfollowunfollow" object:nil];
                
            }

       
                 }];
    }
    
//    else if([request.type intValue]==3){
//           [request.team fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
//                if(!error)
//                {
//                    [request.admin fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
//                        if(!error)
//                        {
//                            [request.admin followTeamWithBlockCallback:request.team completion:^(BOOL succeeded, NSError * _Nullable error) {
//                                if(succeeded)
//                                {
//                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
//                                    
//                                    [request deleteInBackground];
//                                }
//                            }];
//
//                        
//                        }
//                        
//                        
//                        
//                    }];
//
//            }
//                
//            }];
//        }
    
    
}

-(void)FollowAcceptedRequests:(BOOL)isMessage
{
    
 
    
    PFQuery *spotlightQuery = [PFQuery queryWithClassName:@"TeamRequest"];
    [spotlightQuery whereKey:@"user" equalTo:[User currentUser]];
    

    
    
    
   // [spotlightQuery whereKey:@"child" equalTo:[User currentUser].children];

    [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSString *teams = @"";
        __block  NSString *friends = @"";
     
        if(objects.count > 0)
        {
            for(TeamRequest *request in objects)
            {
//                if(request.user.objectId == request.admin.objectId)
//                {
//                    [self deleteTeamRequest:request];
//                }
                
               if(request.requestState.intValue == requestStateAccepted)
                {
                    
                   
                    
                    if(![appDel.acceptedTeamIDs containsObject:request.objectId])
                    {
                        [appDel.acceptedTeamIDs addObject:request.objectId];
                    
                        if([request.type intValue] ==1){
                               teams = (teams.length == 0)? [NSString stringWithFormat:@"%@",request.teamName] : [NSString stringWithFormat:@"%@, %@",teams,request.teamName];
                        }else if([request.type intValue] ==2){
                          [request.admin fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                                
                                User *user = (User*)object;
                                NSString *name = [NSString stringWithFormat:@"%@ %@",user.firstName,user.lastName];
                              friends =   (friends.length == 0)? [NSString stringWithFormat:@"%@",name] : [NSString stringWithFormat:@"%@, %@",friends,name];
                              
                              if(friends.length>0){
                                  [[[UIAlertView alloc] initWithTitle:@""
                                                              message:[NSString stringWithFormat:@"%@ has accepted your friend request",friends]
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] performSelectorOnMainThread:@selector(show)  withObject:nil waitUntilDone:NO];
                              }


                                NSLog(@"friends request%@",user.firstName);
                            } ];
                            
                            
                        }
                        
                        
                    }
                    
                    [self followAcceptedRequest:request];

                }
                
                
                
            }
            
            
            if(teams.length > 0)
            {
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:[NSString stringWithFormat:@"Your follow request for %@ has been accepted",teams]
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] performSelectorOnMainThread:@selector(show)  withObject:nil waitUntilDone:NO];
            }
            
            
        }
        
        
    }];
    
    
    
    
}

-(void)updatePendingMessageRequest
{
    [self FollowAcceptedRequests:true];
    
    PFQuery *spotlightQuery = [PFQuery queryWithClassName:@"TeamRequest"];
    [spotlightQuery whereKey:@"admin" equalTo:[User currentUser]];
    
    [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(objects.count > 0)
        {
            NSMutableArray *array = [NSMutableArray new];
            NSMutableArray *friendsArray = [NSMutableArray new];
            for(TeamRequest *request in objects)
            {
                if( (request.requestState.intValue == reqestStatePending))
                {
                    
                    if([request.type intValue]==1 || [request.type intValue]==3){
                        [array addObject:request];
                    }else  if([request.type intValue]==2){
                        [friendsArray addObject:request];
                    }
                    
                }
                
            }
            if(array.count>0 ){
                [[[self  tabBar]items] objectAtIndex:2].badgeValue = [NSString stringWithFormat:@"%ld",(unsigned long)array.count];
              
            }
            else{
                  [[[self  tabBar]items] objectAtIndex:2].badgeValue  = nil;
            }
            
            if(friendsArray.count>0){
                   [[[self  tabBar]items] objectAtIndex:1].badgeValue = [NSString stringWithFormat:@"%ld",(unsigned long)friendsArray.count];
            }
            else{
              
                 [[[self  tabBar]items] objectAtIndex:1].badgeValue  = nil;
            }
            
            
            
        }
        else{
            [[[self  tabBar]items] objectAtIndex:2].badgeValue  = nil;
             [[[self  tabBar]items] objectAtIndex:1].badgeValue  = nil;
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



-(void)updatePendingRequest
{
    [self FollowAcceptedRequests:false];
    
    PFQuery *spotlightQuery = [PFQuery queryWithClassName:@"TeamRequest"];
    [spotlightQuery whereKey:@"admin" equalTo:[User currentUser]];
    
    [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
           if(objects.count > 0)
        {
            NSMutableArray *array = [NSMutableArray new];
            NSMutableArray *friendsArray = [NSMutableArray new];

            for(TeamRequest *request in objects)
            {
                 if((request.requestState.intValue == reqestStatePending))
                {
                    if([request.type intValue]==1 || [request.type intValue]==3){
                        [array addObject:request];
                    }else  if([request.type intValue]==2){
                        [friendsArray addObject:request];
                    }

                }
                
            }
            if(array.count>0 ){
                [[[self  tabBar]items] objectAtIndex:2].badgeValue = [NSString stringWithFormat:@"%ld",(unsigned long)array.count];
                
            }
            else{
                [[[self  tabBar]items] objectAtIndex:2].badgeValue  = nil;
            }
            
            if(friendsArray.count>0){
                [[[self  tabBar]items] objectAtIndex:1].badgeValue = [NSString stringWithFormat:@"%ld",(unsigned long)friendsArray.count];
            }
            else{
                
                [[[self  tabBar]items] objectAtIndex:1].badgeValue  = nil;
            }
            
            
        }
           else{
               [[[self  tabBar]items] objectAtIndex:2].badgeValue  = nil;
               [[[self  tabBar]items] objectAtIndex:1].badgeValue  = nil;
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


-(void)viewDidUnload{
     [super viewDidUnload];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PendingRequest" object:nil];
      
    }

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
