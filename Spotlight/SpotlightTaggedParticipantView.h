//
//  SpotlightTaggedParticipantView.h
//  Spotlight
//
//  Created by Aakash Gupta on 9/1/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PassTitleAndParticipantProtocol <NSObject>

-(void)addParticipants:(NSArray*)participants withTitle:(NSString*)title;

@end

@interface SpotlightTaggedParticipantView : UIView<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectAll;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectAllCheckmark;


@property (weak, nonatomic) IBOutlet UIView *participantView;
@property (weak, nonatomic) IBOutlet UITextField *txtTitle;
@property (strong, nonatomic) NSMutableArray* teamsMemberArray;
@property (assign, nonatomic) BOOL isSelected;

@property (strong, nonatomic) NSMutableArray* selectedParticantArray;
@property (weak,atomic) id <PassTitleAndParticipantProtocol> delegate;

- (instancetype)initWithParticipants:(NSArray*)participants selectedParticipants:(NSArray*)selectedParticipants title:(NSString*)title;

@end
