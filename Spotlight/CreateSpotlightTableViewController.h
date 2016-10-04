//
//  CreateSpotlightTableViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 11/20/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Team;

@interface CreateSpotlightTableViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>

@property(strong, nonatomic) Team* team;
@property(assign, nonatomic) BOOL isFromTeamdetail;

@end
