//
//  TeamDetailsTableViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 11/26/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Team;

@interface TeamDetailsTableViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) Team* team;

@end
