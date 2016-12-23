//
//  DateFieldTableViewCell.m
//  Spotlight
//
//  Created by Peter Kamm on 12/14/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import "DateFieldTableViewCell.h"

@interface DateFieldTableViewCell () <UITextFieldDelegate, UIToolbarDelegate>

@property (strong, nonatomic)UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *fieldTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;


@end

@implementation DateFieldTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)focusTextField {
    [self.valueTextField becomeFirstResponder];
}

- (void)formatWithDateValue:(NSDate*)date
                    isCenter:(BOOL)isCenter {

    self.date = [NSDate date];
    NSString* displayText = @"Birthdate";

    [self.fieldTitleLabel setText:displayText];
    _valueTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:displayText attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    if(isCenter){
        _valueTextField.textAlignment = NSTextAlignmentCenter;
        _valueTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:displayText attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    }
    
    self.datePicker = [[UIDatePicker alloc] init];
    [self.datePicker setDate:[NSDate date]];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    [self.datePicker setMaximumDate:[NSDate date]];
    [self.datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    [self.valueTextField setInputView:self.datePicker];
    
    //add the done button
    
    UIToolbar* doneBar = [[UIToolbar alloc] init];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self.delegate action:@selector(createAccountButtonPressed:)];
    [doneBar setItems:@[doneButton]];
    [doneBar sizeToFit];
    
    self.valueTextField.inputAccessoryView = doneBar;
}

-(void)updateTextField:(id)sender {
    UIDatePicker *picker = (UIDatePicker*)self.valueTextField.inputView;
    self.date = picker.date;
    self.valueTextField.text = [self formatDate:picker.date];
    [self.delegate setUserDOB:self.date];
}

- (NSString *)formatDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return formattedDate;
}

@end
