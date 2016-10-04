//
//  SpotlightTaggedParticipantView.m
//  Spotlight
//
//  Created by Aakash Gupta on 9/1/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import "SpotlightTaggedParticipantView.h"
#import "TaggedParticipantTableViewCell.h"
#import "Child.h"
#import "User.h"

@implementation SpotlightTaggedParticipantView
    


- (instancetype)initWithParticipant:(NSArray*)participantArray withTitle:(NSString*)title{
    self = [[[NSBundle mainBundle] loadNibNamed:@"SpotlightTaggedParticipantView" owner:self options:nil] objectAtIndex:0];
    
    if (self = [super init]) {
        self.teamsMemberArray = participantArray.mutableCopy;
    }
    return self;
}

- (void)awakeFromNib {
 
    _selectedParticantArray = [NSMutableArray new];
    
    
    // border
    self.participantView.layer.cornerRadius = 10;
    self.participantView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.participantView.layer.borderWidth = 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.teamsMemberArray.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Child *child;
    User *user;
    static NSString *CellIdentifier = @"tagParticipantMultiple";
    
    TaggedParticipantTableViewCell *cell = (TaggedParticipantTableViewCell *)[tableView     dequeueReusableCellWithIdentifier:CellIdentifier];
   // NSMutableArray *partcipant  = [_teamsMemberArray objectAtIndex:indexPath.row];
    
    if ([_teamsMemberArray[indexPath.row] isKindOfClass:[Child class]]){
        child   = _teamsMemberArray[indexPath.row];
        
    }
    else{
           user   = _teamsMemberArray[indexPath.row];
    }

    
    
    
    
    
    
    
    if (cell == nil) {
        
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TaggedParticipantTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
//    if(indexPath.row == 0){
//        cell.lblHeader.text = @"Select All";
//
//    }else{
//        [cell formatForParticipantName:user and:child];
//
//        
//    }
     [cell formatForParticipantName:user and:child];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setNeedsLayout];
    [cell.contentView layoutIfNeeded];


return cell;
    
    
      
}



- (IBAction)okBtnClicked:(id)sender {
    
    NSLog(@"selected array is %@",_selectedParticantArray);
    [self.delegate participant:_selectedParticantArray.mutableCopy withTitle:_txtTitle.text];
    [self removeFromSuperview];
}

- (IBAction)selectAllBtnClicked:(id)sender {
    
    if(!self.isSelected){
        for (int i = 0; i < [self.tableView numberOfSections]; i++) {
            for (int j = 0; j < [self.tableView numberOfRowsInSection:i]; j++) {
                NSUInteger ints[2] = {i,j};
                NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
                TaggedParticipantTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                //Here is your code
                [cell.btnCheckMark setImage:[UIImage imageNamed:@"Checked"] forState:UIControlStateNormal];
            }
        }
        [self.btnSelectAllCheckmark setImage:[UIImage imageNamed:@"Checked"] forState:UIControlStateNormal];


        [self.btnSelectAll setTitle:@"Deselect All" forState:UIControlStateNormal];

        [_selectedParticantArray  addObjectsFromArray:_teamsMemberArray];
        self.isSelected = true;
    }
    else{
        for (int i = 0; i < [self.tableView numberOfSections]; i++) {
            for (int j = 0; j < [self.tableView numberOfRowsInSection:i]; j++) {
                NSUInteger ints[2] = {i,j};
                NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
                TaggedParticipantTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                //Here is your code
                [cell.btnCheckMark setImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];
             
            }
        }
        [self.btnSelectAll setTitle:@"Select All" forState:UIControlStateNormal];
        [self.btnSelectAllCheckmark setImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];

        [_selectedParticantArray removeAllObjects];
        self.isSelected = false;
    }
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TaggedParticipantTableViewCell *cell = (TaggedParticipantTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
      [cell.btnCheckMark setImage:[UIImage imageNamed:@"Checked"] forState:UIControlStateNormal];
    Child *child;
    User *user;
    
//    if(indexPath.row == 0){
//        [_selectedParticantArray  addObjectsFromArray:_teamsMemberArray];
//
//        
//    }else{
        if ([_teamsMemberArray[indexPath.row] isKindOfClass:[Child class]]){
            child   = _teamsMemberArray[indexPath.row];
            [_selectedParticantArray  addObject:child];
        }
        else{
            user   = _teamsMemberArray[indexPath.row];
            [_selectedParticantArray  addObject:user];
        }

        
        
   // }
   
  
   
    
    
    
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    TaggedParticipantTableViewCell *cell = (TaggedParticipantTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.btnCheckMark setImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];
    Child *child;
    User *user;
    if ([_teamsMemberArray[indexPath.row] isKindOfClass:[Child class]]){
        child   = _teamsMemberArray[indexPath.row];
        [_selectedParticantArray  removeObject:child];
    }
    else{
        user   = _teamsMemberArray[indexPath.row];
        [_selectedParticantArray  removeObject:user];
    }
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn:");
    [textField resignFirstResponder];
          return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
