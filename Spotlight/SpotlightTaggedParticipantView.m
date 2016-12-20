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
#import "MWPhotoBrowser.h"

@interface SpotlightTaggedParticipantView()

@property (strong, nonatomic) NSString* titleText;

@end

@implementation SpotlightTaggedParticipantView

- (instancetype)initWithParticipants:(NSArray*)participants selectedParticipants:(NSArray*)selectedParticipants title:(NSString*)title{
    self = [[[NSBundle mainBundle] loadNibNamed:@"SpotlightTaggedParticipantView" owner:self options:nil] objectAtIndex:0];
    
    if (self = [super init]) {
        self.teamsMemberArray = participants.mutableCopy;
        self.selectedParticantArray = selectedParticipants.mutableCopy;
        self.titleText = title;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.participantView.layer.cornerRadius = 10;
    self.participantView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.participantView.layer.borderWidth = 1;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.txtTitle.text = self.titleText;
    [self checkSelectAllButton];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.teamsMemberArray.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"tagParticipantMultiple";
    
    TaggedParticipantTableViewCell *cell = (TaggedParticipantTableViewCell *)[tableView     dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TaggedParticipantTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    NSString* name = [self childOrUserName:_teamsMemberArray[indexPath.row]];
    [cell formatForName:name];
    
    BOOL isHighlighted = ([self.selectedParticantArray containsObject:name]);
    [cell.btnCheckMark setHighlighted:isHighlighted];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setNeedsLayout];
    [cell.contentView layoutIfNeeded];

    return cell;  
}

- (NSString*)childOrUserName:(id)userOrChild {
    if ([userOrChild isKindOfClass:[Child class]] || [userOrChild isKindOfClass:[User class]]){
        return [NSString stringWithFormat:@"%@ %@",
                          [userOrChild firstName],
                          [userOrChild lastName]];
    }
    return nil;
}


- (IBAction)okBtnClicked:(id)sender {
    NSLog(@"selected array is %@",_selectedParticantArray);
    
    NSMutableArray* users = [NSMutableArray arrayWithCapacity:[_selectedParticantArray count]];
    for (id user in self.teamsMemberArray) {
        if ([self.selectedParticantArray containsObject:[self childOrUserName:user]]) {
            [users addObject:user];
        }
    }
    [self.delegate addParticipants:users.mutableCopy withTitle:_txtTitle.text];
    [self removeFromSuperview];
}

- (IBAction)selectAllBtnClicked:(id)sender {
    
    if(!self.isSelected){
        for (id user in _teamsMemberArray) {
            [_selectedParticantArray addObject:[self childOrUserName:user]];
        }
        self.isSelected = YES;
        [self.btnSelectAllCheckmark setHighlighted:YES];
    } else{
        [_selectedParticantArray removeAllObjects];
        self.isSelected = NO;
        [self.btnSelectAllCheckmark setHighlighted:NO];
    }
    [self.tableView reloadData];
}

- (void)checkSelectAllButton {
    if ([self.teamsMemberArray count] == [self.selectedParticantArray count]) {
        self.isSelected = YES;
        [self.btnSelectAllCheckmark setHighlighted:YES];
    } else {
        self.isSelected = NO;
        [self.btnSelectAllCheckmark setHighlighted:NO];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TaggedParticipantTableViewCell *cell = (TaggedParticipantTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell.btnCheckMark isHighlighted]) {
        [cell.btnCheckMark setHighlighted:NO];
        [_selectedParticantArray removeObject:[self childOrUserName:_teamsMemberArray[indexPath.row]]];
    } else {
        [cell.btnCheckMark setHighlighted:YES];
        [_selectedParticantArray addObject:[self childOrUserName:_teamsMemberArray[indexPath.row]]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self checkSelectAllButton];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn:");
    [textField resignFirstResponder];
          return YES;
}

@end
