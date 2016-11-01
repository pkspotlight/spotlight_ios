//
//  TaggedParticipantTableViewCell.m
//  Spotlight
//
//  Created by Aakash Gupta on 9/1/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import "TaggedParticipantTableViewCell.h"

@implementation TaggedParticipantTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)formatForParticipantName:(User*)user and:(Child*)child{
    if(child!=nil){
        NSString *name = [NSString stringWithFormat:@"%@ %@",child.firstName
                          ,child.lastName];
         self.lblHeader.text = name;
    }else{
        NSString *name = [NSString stringWithFormat:@"%@ %@",user.firstName
                          ,user.lastName];
         self.lblHeader.text = name;
    }
    
    
}



@end
