//
//  SpotlightTaggedParticipantView.h
//  Spotlight
//
//  Created by Aakash Gupta on 9/1/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PassTitleAndParticipantProtocol <NSObject>

-(void)participant:(NSArray*)participant withTitle:(NSString*)title;


@end

@interface SpotlightTaggedParticipantView : UIView<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIView *participantView;
@property (weak, nonatomic) IBOutlet UITextField *txtTitle;
@property (strong, nonatomic) NSMutableArray* teamsMemberArray;
@property (strong, nonatomic) NSMutableArray* selectedParticantArray;
@property (weak,atomic) id <PassTitleAndParticipantProtocol> delegate;

- (instancetype)initWithParticipant:(NSArray*)participantArray withTitle:(NSString*)title;
@end
