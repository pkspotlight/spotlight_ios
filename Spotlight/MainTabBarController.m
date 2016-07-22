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



-(void)updatePendingRequest
{
    
    PFQuery *spotlightQuery = [PFQuery queryWithClassName:@"TeamRequest"];
    [spotlightQuery whereKey:@"admin" equalTo:[User currentUser]];
    
    [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
           if(objects.count > 0)
        {
            NSMutableArray *array = [NSMutableArray new];
            for(TeamRequest *request in objects)
            {
                if(request.user.objectId != request.admin.objectId)
                {
                    [array addObject:request];
                }
                
            }
            [[[self  tabBar]items] objectAtIndex:2].badgeValue = [NSString stringWithFormat:@"%ld",array.count];
            
            
        }
        else{
            [[self navigationController] tabBarItem].badgeValue  = @"";
        }
        
        for(TeamRequest *request in objects)
        {
            [request.admin fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                //   NSString *data =[NSString stringWithFormat:@"%@       %@",request.admin.firstName,request.user.firstName];
                
                NSLog(@"%@",request.admin.firstName);
            }];
            
            
            
        }
        
    }];

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
