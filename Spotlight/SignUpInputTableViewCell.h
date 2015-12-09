//
//  SignUpInputTableViewCell.h
//  Spotlight
//
//  Created by Peter Kamm on 9/9/15.
//  Copyright (c) 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SignUpInputTableViewCell;

@protocol SignupInputTextFieldDelegate <NSObject>

- (void)inputTextFieldCell:(SignUpInputTableViewCell*)cell didChangeToValue:(NSString*)text;

@end

@interface SignUpInputTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) NSString* fieldName;
@property (weak, nonatomic) IBOutlet UILabel *fieldNameLabel;


@property(weak) id<SignupInputTextFieldDelegate> delegate;

@end
