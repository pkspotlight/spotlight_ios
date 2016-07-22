//
//  TeamRequest.m
//  Spotlight
//
//  Created by Aakash Gupta on 7/21/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import "TeamRequest.h"

@implementation TeamRequest
@dynamic child;
@dynamic user;
@dynamic timeStamp;
@dynamic team;
@dynamic admin;
@dynamic nameOfRequester;
@dynamic PicOfRequester;
@dynamic requestState;
@dynamic isChild;
@dynamic teamName;
+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"TeamRequest";
}
- (void)saveTeam:(Team*)team andAdmin:(User*)admin followby:(User*)user  orChild:(Child*)child withTimestamp:(NSString*)time isChild:(NSNumber*)isChild completion:(void (^)(void))completion{
//    [[self teams] addObject:team];
    self.team = team;
    self.user = user;
    self.child = child;
    self.timeStamp = time;
    self.admin = admin;
    self.requestState = [NSNumber numberWithInt:reqestStatePending];
     self.isChild = isChild;
    if(!isChild)
    {
        self.nameOfRequester = [NSString stringWithFormat:@"%@ %@",user.firstName,user.lastName];
        self.PicOfRequester = user.profilePic;
       
    }
    else
    {
        self.nameOfRequester = [NSString stringWithFormat:@"%@ %@",child.firstName,child.lastName];
        self.PicOfRequester = child.profilePic;
     

    }
    self.teamName = team.teamName;
    
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            NSLog(@"success team");
            
            [[[UIAlertView alloc] initWithTitle:@""
                                        message:@"Your request has been sent to Admin"
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
            
          //  [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
        }
        if (completion) {
            
            completion();
        }
    }];
}

//- (void)unfollowTeam:(Team*)team completion:(void (^)(void))completion{
//    [[self teams] removeObject:team];
//    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//        if(succeeded){
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
//        }
//        if (completion) {
//            completion();
//        }
//    }];
//}


@end
