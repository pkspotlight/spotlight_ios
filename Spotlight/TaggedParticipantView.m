//
//  TaggedParticipantView.m
//  Spotlight
//
//  Created by Aakash Gupta on 9/20/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import "TaggedParticipantView.h"
#import "TaggedParticipantTableViewCell.h"

@implementation TaggedParticipantView

- (instancetype)initWithParticipant:(NSArray*)participantArray{
    self = [[[NSBundle mainBundle] loadNibNamed:@"TaggedParticipantView" owner:self options:nil] objectAtIndex:0];
    if (self = [super init]) {
        self.participantArray = participantArray.mutableCopy;
    }
    return self;
}

- (void)awakeFromNib {

    [super awakeFromNib];
    self.participantView.layer.cornerRadius = 10;
    self.participantView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.participantView.layer.borderWidth = 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? self.participantArray.count : 1;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"tagParticipantMultiple";
        
        TaggedParticipantTableViewCell *cell = (TaggedParticipantTableViewCell *)[tableView     dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TaggedParticipantTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.lblHeader.text = _participantArray[indexPath.row];
        cell.btnCheckMark.hidden = YES;
        cell.btnCheckMarkWidth.constant = 0;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setNeedsLayout];
        [cell.contentView layoutIfNeeded];
        
        
        return cell;
    } else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddMoreTaggedParticipants"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AddMoreTaggedParticipantsTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if ([self.delegate respondsToSelector:@selector(showTagParticipantView:)]) {
            [self.delegate performSelector:@selector(showTagParticipantView:) withObject:self.participantArray];
            [self removeFromSuperview];
        }
    }
}

- (IBAction)removeSpotlightBoardingView:(id)sender {
    [self removeFromSuperview];
}


@end
