//
//  ProfileTableViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse.h>

@interface ProfileTableViewController : UITableViewController  <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property(strong, nonatomic) PFUser* user;

@end
