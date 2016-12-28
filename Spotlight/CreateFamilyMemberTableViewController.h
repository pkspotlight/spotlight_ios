//
//  CreateFamilyMemberTableViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 2/8/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FieldEntryTableViewCell.h"
#import "DateFieldTableViewCell.h"

@interface CreateFamilyMemberTableViewController : UITableViewController <FieldEntryTextFieldCellDelegate, DateFieldTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@end
