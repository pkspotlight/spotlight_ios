//
//  ProfileTableViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FieldEntryTableViewCell.h"
#import <MessageUI/MessageUI.h>

@class User;

@interface ProfileTableViewController : UITableViewController  <FieldEntryTextFieldCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate>

@property(strong, nonatomic) User* user;

@end
