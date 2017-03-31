//
//  Organization.h
//  Spotlight
//
//  Created by Peter Kamm on 3/21/17.
//  Copyright © 2017 Spotlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/PFObject.h"
#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import "TeamLogoMedia.h"

@interface Organization : PFObject <PFSubclassing>

@property (strong, nonatomic) TeamLogoMedia* orgLogo;
@property (strong, nonatomic) NSString* orgName;
@property (readonly, nonatomic) PFRelation* orgOwners;
//@property (readonly, nonatomic) PFRelation* teams;

+ (NSString *)parseClassName;

@end
