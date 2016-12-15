//
//  DateFieldTableViewCell.h
//  Spotlight
//
//  Created by Peter Kamm on 12/14/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DateFieldTableViewCell;

@protocol DateFieldTableViewCellDelegate <NSObject>

@property (strong, nonatomic) NSDate* userDOB;

- (void)createAccountButtonPressed:(id)sender;

@end


@interface DateFieldTableViewCell : UITableViewCell

@property (strong, nonatomic) NSDate *date;

- (void)focusTextField;
- (void)formatWithDateValue:(NSDate*)date
                   isCenter:(BOOL)isCenter;

@property (weak, nonatomic) id<DateFieldTableViewCellDelegate> delegate;

@end
