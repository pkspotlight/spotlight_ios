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

- (void)formatForAttributeString:(NSString*)attributeString withValue:(NSString*)fieldValue {
    _attributeString = attributeString;
    [self.fieldTitleLabel setText:[attributeString capitalizedString]];
    [self.valueTextField setText:fieldValue];
}

- (IBAction)textFieldTextDidChange:(UITextField *)sender {
    [self.delegate accountTextFieldCell:self didChangeToValue:sender.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.delegate accountTextFieldCellDidReturn:self];
    return NO;
}

@end
