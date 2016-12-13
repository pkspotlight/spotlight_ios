//
//  FriendProfileViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 12/1/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class User;
@class Child;

@interface FriendProfileViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) User* user;
@property (strong, nonatomic) Child* child;

@end
