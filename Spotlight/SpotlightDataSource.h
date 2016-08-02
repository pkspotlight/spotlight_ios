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
@property (weak,atomic) id <RefreshTableDelegate> delegate;
- (void)loadSpotlights:(void (^)(void))completion;

@end
