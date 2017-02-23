//
//  SpotlightDataSource.h
//  Spotlight
//
//  Created by Peter Kamm on 12/8/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MBProgressHUD.h>
#import "SpotlightCollectionViewController.h"

@protocol RefreshTableDelegate <NSObject>

-(void)spotlightDeleted:(MBProgressHUD *)hud;

@end

@class User;
@class Team;
@class Child;

@interface SpotlightDataSource : NSObject <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

- (instancetype)initWithUser:(User*)user;
- (instancetype)initWithTeam:(Team*)team;
- (instancetype)initWithChild:(Child*)child;
@property (weak,atomic) UIViewController <RefreshTableDelegate>* delegate;
@property (assign,nonatomic)  BOOL doesCheckForPrivacy;;

- (void)loadSpotlights:(void (^)(void))completion;

@end
