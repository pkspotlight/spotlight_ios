//
//  Team.h
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFObject.h"
#import <Parse.h>
#import <Parse/PFObject+Subclass.h>
#import "TeamLogoMedia.h"


@interface Team : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (strong, nonatomic) NSString* teamName;
@property (strong, nonatomic) TeamLogoMedia* teamLogoMedia;


@end
