//
//  SignUpTableViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 9/9/15.
//  Copyright (c) 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FieldEntryTableViewCell.h"

@interface SignUpTableViewController : UITableViewController <FieldEntryTextFieldCellDelegate>

@property (assign, nonatomic) BOOL isLoginScreen;

@end
