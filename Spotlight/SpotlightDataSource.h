//
//  SpotlightDataSource.h
//  Spotlight
//
//  Created by Peter Kamm on 12/8/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class User;
@class Team;

@interface SpotlightDataSource : NSObject <UITableViewDataSource>

- (instancetype)initWithUser:(User*)user;
- (instancetype)initWithTeam:(Team*)team;

- (void)loadSpotlights:(void (^)(void))completion;

@end
