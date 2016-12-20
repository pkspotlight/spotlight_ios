//
//  TaggedParticipantTableViewCell.h
//  Spotlight
//
//  Created by Aakash Gupta on 9/1/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Child.h"
@interface TaggedParticipantTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckMark;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnCheckMarkWidth;

- (void)formatForName:(NSString*)name;

@end
