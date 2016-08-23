//
//  TeamRequest.h
//  Spotlight
//
//  Created by Aakash Gupta on 7/21/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import "PFObject.h"
#import "Child.h"
#import "Team.h"
#import "User.h"

enum requestStates{
    reqestStatePending = 1,
    requestStateAccepted,
    requestStateRejected
};
enum type{
    typeTeam = 1,
    typeFriend
    
};


@interface TeamRequest : PFObject  <PFSubclassing>
+ (NSString *)parseClassName;


@property (strong, nonatomic) Child *child;
@property (strong, nonatomic) Team *team;
@property (strong, nonatomic) User* user;
@property (assign, nonatomic) NSString *timeStamp;
@property (assign, nonatomic) User *admin;
@property (assign, nonatomic) NSString *nameOfRequester;
@property (assign, nonatomic) NSString *teamName;
@property (assign, nonatomic) NSNumber *requestState;
@property (assign, nonatomic) NSNumber *isChild;
@property (assign, nonatomic) NSNumber *type;

@property (strong, nonatomic) ProfilePictureMedia* PicOfRequester;


//- (void)saveTeam:(Team*)team andAdmin:(User*)admin followby:(User*)user  orChild:(Child*)child withTimestamp:(NSString*)time isChild:(NSNumber*)isChild completion:(void (^)(void))completion;
- (void)saveTeam:(Team*)team andAdmin:(User*)admin followby:(User*)user  orChild:(Child*)child withTimestamp:(NSString*)time isChild:(NSNumber*)isChild isType:(NSNumber*)type completion:(void (^)(void))completion;
@end
