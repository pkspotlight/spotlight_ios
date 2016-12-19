//
//  UIViewController+MediaAddingFunctionality.h
//  Spotlight
//
//  Created by Peter Kamm on 12/17/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Spotlight.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"


@interface UIViewController (MediaAddingFunctionality) <ELCImagePickerControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) UIImagePickerController* imagePickerController;
@property (strong, nonatomic) Spotlight* spotlight;
@property (copy) void (^completion)(void);


- (IBAction)addMediaButtonPressedCompletion:(void (^)())completion;


@end
