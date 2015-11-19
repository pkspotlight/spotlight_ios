//
//  TeamTableViewCell.m
//  Spotlight
//
//  Created by Peter Kamm on 11/18/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "TeamTableViewCell.h"
#import "Team.h"

@interface TeamTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *teamNameLabel;


@end

@implementation TeamTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)formatForTeam:(Team*)team {
    
    [self.teamNameLabel setText:team[@"name"]];
}

@end
