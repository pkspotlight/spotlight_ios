//
//  CreateSpotlightViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 10/19/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ContactsUI/ContactsUI.h>

#import "ELCImagePickerController.h"

@class Team;

@interface CreateSpotlightViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CNContactPickerDelegate>

@property (strong, nonatomic) Team* team;

@end
