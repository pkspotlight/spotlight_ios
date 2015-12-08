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

- (void)focusTextField;

- (void)formatForAttributeString:(NSString*)attributeString withValue:(NSString*)fieldValue;

@property (readonly, nonatomic) NSString *attributeString;


//- (void)displayField:(SEMTemplateField *)field
//               value:(NSString *)value
//           returnKey:(UIReturnKeyType)returnKeyType
// showProtectedValues:(BOOL)showProtectedFields
//showImportPasswordButton:(BOOL)showImport;

@property (weak, nonatomic) id<FieldEntryTextFieldCellDelegate> delegate;

@end