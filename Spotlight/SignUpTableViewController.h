//
//  SignUpTableViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 9/9/15.
//  Copyright (c) 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FieldEntryTableViewCell.h"
#import "DateFieldTableViewCell.h"


@interface SignUpTableViewController : UITableViewController <FieldEntryTextFieldCellDelegate, DateFieldTableViewCellDelegate>

@property (assign, nonatomic) BOOL isLoginScreen;
@property (strong, nonatomic) NSDate* userDOB;

@end
