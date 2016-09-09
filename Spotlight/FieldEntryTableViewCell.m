//
//  FieldEntryTableViewCell.m
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "FieldEntryTableViewCell.h"


@interface FieldEntryTableViewCell () <UITextFieldDelegate, UIToolbarDelegate>

//@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@property (weak, nonatomic) IBOutlet UILabel *fieldTitleLabel;

@end

@implementation FieldEntryTableViewCell

- (void)focusTextField {
    [self.valueTextField becomeFirstResponder];
}

- (void)formatForAttributeString:(NSString*)attributeString
                     displayText:(NSString*)displayText
                       withValue:(NSString*)fieldValue isCenter:(BOOL)isCenter{
    _attributeString = attributeString;
    
 
    [self.valueTextField setText:fieldValue];
    [self.fieldTitleLabel setText:displayText];
     _valueTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:displayText attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:146.0/255.0f green:146.0/255.0f blue:146.0/255.0f alpha:1.0]}];
    if(isCenter){
         _valueTextField.textAlignment = NSTextAlignmentCenter;
         _valueTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:displayText attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    }
   
  
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
