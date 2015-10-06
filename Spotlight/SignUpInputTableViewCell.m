//
//  SignUpInputTableViewCell.m
//  Spotlight
//
//  Created by Peter Kamm on 9/9/15.
//  Copyright (c) 2015 Spotlight. All rights reserved.
//

#import "SignUpInputTableViewCell.h"

@implementation SignUpInputTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)textFieldTextDidChange:(id)sender {
    UITextField* textField = (UITextField*)sender;
    [self.delegate inputTextFieldCell:self didChangeToValue:textField.text];
}

@end
