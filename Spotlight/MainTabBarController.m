//
//  MainTabBarController.m
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "MainTabBarController.h"
#import "Parse.h"
#import "User.h"
#import "Child.h"
#import "TeamRequest.h"
@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePendingRequest) name:@"PendingRequest" object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)deleteTeamRequest:(TeamRequest *)request
{
    [request deleteInBackground];
}

-(void)followAcceptedRequest:(TeamRequest *)request
{
  
    if(!request.isChild.boolValue)
    {
        [request.team fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if(!error)
            {
            [[User currentUser] followTeamWithBlockCallback:request.team completion:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded)
                {
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
                    [request.child followTeamWithBlockCallback:request.team completion:^(BOOL succeeded, NSError * _Nullable error) {
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

-(void)FollowAcceptedRequests
{
    
 
    
    PFQuery *spotlightQuery = [PFQuery queryWithClassName:@"TeamRequest"];
    [spotlightQuery whereKey:@"user" equalTo:[User currentUser]];
    

    
    
    
   // [spotlightQuery whereKey:@"child" equalTo:[User currentUser].children];

    [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(objects.count > 0)
        {
            for(TeamRequest *request in objects)
            {
                if(request.user.objectId == request.admin.objectId)
                {
                    [self deleteTeamRequest:request];
                }
                
               else if(request.requestState.intValue == requestStateAccepted)
                {
                    [self followAcceptedRequest:request];

                }
                
                
                
            }
        }
        
        
    }];
    
    
    
    
}


-(void)updatePendingRequest
{
    [self FollowAcceptedRequests];
    
    PFQuery *spotlightQuery = [PFQuery queryWithClassName:@"TeamRequest"];
    [spotlightQuery whereKey:@"admin" equalTo:[User currentUser]];
    
    [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
           if(objects.count > 0)
        {
            NSMutableArray *array = [NSMutableArray new];
            for(TeamRequest *request in objects)
            {
                 if((request.user.objectId != request.admin.objectId) && (request.requestState.intValue == reqestStatePending))
                {
                    [array addObject:request];
                }
                
            }
            if(array.count>0){
            [[[self  tabBar]items] objectAtIndex:2].badgeValue = [NSString stringWithFormat:@"%ld",array.count];
            }
            else{
                  [[[self  tabBar]items] objectAtIndex:2].badgeValue  = nil;
            }
            
            
        }
        else{
            [[[self  tabBar]items] objectAtIndex:2].badgeValue  = nil;
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
