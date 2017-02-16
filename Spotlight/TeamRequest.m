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
@dynamic type;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"TeamRequest";
}
- (void)saveTeam:(Team*)team
        andAdmin:(User*)admin
        followby:(User*)user
         orChild:(Child*)child
   withTimestamp:(NSString*)time
         isChild:(NSNumber*)isChild
          isType:(NSNumber*)type
      completion:(void (^)(void))completion {
    
    self.team = team;
    self.user = user;
    self.child = child;
    self.timeStamp = time;
    self.admin = admin;
    self.type = type;
    self.requestState = [NSNumber numberWithInt:reqestStatePending];
    self.isChild = isChild;
    
    if([self.type intValue]==1 || [self.type intValue]==3){
        
        if(!isChild.boolValue){
            self.nameOfRequester = [NSString stringWithFormat:@"%@ %@",user.firstName,user.lastName];
            self.PicOfRequester = user.profilePic;
        } else {
            self.nameOfRequester = [NSString stringWithFormat:@"%@ %@",child.firstName,child.lastName];
            self.PicOfRequester = child.profilePic;
        }
        self.teamName = team.teamName;
        
        [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded){
                NSLog(@"success team");
                
                if([self.type intValue]==1){
                    [[[UIAlertView alloc] initWithTitle:@""
                                                message:@"Your follow request has been sent. If the account admin accepts your request, the team will appear on your teams list."
                                               delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
                    
                }else{
                    [[[UIAlertView alloc] initWithTitle:@""
                                                message:@"Your invite has been sent."
                                               delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
                }
                if (completion) completion();
            }else{
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:@"We are unable to send your request. Please try again later"
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
            }
        }];
    } else if([self.type intValue]==2){
        self.nameOfRequester = [NSString stringWithFormat:@"%@ %@",user.firstName,user.lastName];
        self.PicOfRequester = user.profilePic;
        [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded){
                NSLog(@"success team");
                
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:@"Your follow request has been sent. If the account admin accepts your request, he/she will appear on your friend list."
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
                if (completion) completion();
            } else {
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:@"We are unable to send your request. Please try again later"
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
            }
        }];
    }
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
