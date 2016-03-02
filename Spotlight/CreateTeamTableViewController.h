//
//  CreateTeamTableViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FieldEntryTableViewCell.h"

@class Team;

@interface CreateTeamTableViewController : UITableViewController <FieldEntryTextFieldCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) Team* team;

@end
