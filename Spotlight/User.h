//
//  User.h
//  Spotlight
//
//  Created by Peter Kamm on 12/5/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <Parse/Parse.h>

@class ProfilePictureMedia;

@interface User : PFUser <PFSubclassing>

@property (strong, nonatomic) ProfilePictureMedia* profileImage;
@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;


@end
