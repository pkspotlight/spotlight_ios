//
//  TaggedParticipantView.h
//  Spotlight
//
//  Created by Aakash Gupta on 9/20/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaggedParticipantView : UIView<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) NSMutableArray* participantArray;
@property (weak, nonatomic) IBOutlet UIView *participantView;
- (instancetype)initWithParticipant:(NSArray*)participantArray withTitle:(NSString*)title;

@end
