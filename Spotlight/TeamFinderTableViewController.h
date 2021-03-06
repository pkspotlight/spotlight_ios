//
//  TeamFinderTableViewController.h
//  Spotlight
//
//  Created by Peter Kamm on 2/19/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TeamTableViewCell.h"
#import "TeamRequest.h"

@interface TeamFinderTableViewController : UITableViewController <TeamTableViewCellDelegate>
@property(strong, nonatomic) TeamRequest* teamRequest;

- (void)followButtonPressed:(TeamTableViewCell*)teamCell completion:(void (^)(void))completion;

@end
