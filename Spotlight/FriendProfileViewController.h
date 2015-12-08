//
//  FriendProfileViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 12/1/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse.h>

@class User;

@interface FriendProfileViewController : UIViewController

@property (strong, nonatomic) User* user;

@end
