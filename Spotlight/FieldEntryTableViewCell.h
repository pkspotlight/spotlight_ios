//
//  FieldEntryTableViewCell.h
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FieldEntryTableViewCell;

@protocol FieldEntryTextFieldCellDelegate <NSObject>

- (void)accountTextFieldCell:(FieldEntryTableViewCell *)cell didChangeToValue:(NSString *)text;
- (void)accountTextFieldCellDidReturn:(FieldEntryTableViewCell *)cell;

@end

@interface FieldEntryTableViewCell : UITableViewCell <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;

- (void)focusTextField;

- (void)formatForAttributeString:(NSString*)attributeString
                     displayText:(NSString*)displayText
                       withValue:(NSString*)fieldValue isCenter:(BOOL)isCenter;
    
- (void)setKeyboardType:(UIKeyboardType)keyboardType;
- (void)setIsSecure:(BOOL)isSecure;
- (void)setAutoCapitalizationType:(UITextAutocapitalizationType)capType;

@property (readonly, nonatomic) NSString *attributeString;


@property (weak, nonatomic) id<FieldEntryTextFieldCellDelegate> delegate;

@end
