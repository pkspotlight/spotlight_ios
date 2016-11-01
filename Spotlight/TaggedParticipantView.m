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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithParticipant:(NSArray*)participantArray withTitle:(NSString*)title{
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
    return self.participantArray.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    static NSString *CellIdentifier = @"tagParticipantMultiple";
    
    TaggedParticipantTableViewCell *cell = (TaggedParticipantTableViewCell *)[tableView     dequeueReusableCellWithIdentifier:CellIdentifier];
    // NSMutableArray *partcipant  = [_teamsMemberArray objectAtIndex:indexPath.row];
    
       
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
    
    
    
}





- (IBAction)removeSpotlightBoardingView:(id)sender {
    [self removeFromSuperview];
}


@end
