//
//  Team.h
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/PFObject.h"
#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import "TeamLogoMedia.h"


@interface Team : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (strong, nonatomic) NSString* teamName;

@property (strong, nonatomic) TeamLogoMedia* teamLogoMedia;
@property (strong, nonatomic) NSString* year;
@property (strong, nonatomic) NSString* sport;
@property (strong, nonatomic) NSString* season;
@property (strong, nonatomic) NSString* town;
@property (strong, nonatomic) NSString* grade;
@property (strong, nonatomic) NSMutableArray* spectatorsArray;
@property (readonly, nonatomic) PFRelation* moderators;
@property (readonly, nonatomic) PFRelation* organization;


@end
