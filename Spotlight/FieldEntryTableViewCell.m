//
//  FieldEntryTableViewCell.m
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "FieldEntryTableViewCell.h"


@interface FieldEntryTableViewCell () <UITextFieldDelegate, UIToolbarDelegate>

@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@property (weak, nonatomic) IBOutlet UILabel *fieldTitleLabel;

@end

@implementation FieldEntryTableViewCell

- (void)focusTextField {
    [self.valueTextField becomeFirstResponder];
}

- (void)formatForAttributeString:(NSString*)attributeString
                     displayText:(NSString*)displayText
                       withValue:(NSString*)fieldValue {
    _attributeString = attributeString;
    
 
    [self.valueTextField setText:fieldValue];
     _valueTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:displayText attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    _valueTextField.textAlignment = NSTextAlignmentCenter;
  
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType {
    [self.valueTextField setKeyboardType:keyboardType];
}

- (void)setIsSecure:(BOOL)isSecure {
    [self.valueTextField setSecureTextEntry:isSecure];
}

- (IBAction)textFieldTextDidChange:(UITextField *)textField {
    [self.delegate accountTextFieldCell:self didChangeToValue:textField.text];
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self.delegate accountTextFieldCell:self didChangeToValue:textField.text];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.delegate accountTextFieldCellDidReturn:self];
    return NO;
}

@end
