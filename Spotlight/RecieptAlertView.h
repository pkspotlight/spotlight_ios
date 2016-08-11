//
//  RecieptAlertView.h
//  APPvantage
//
//  Created by Yashika Garg on 01/06/16.
//  Copyright © 2016 Algoworks Technologies Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RecieptAlertViewDelegate
@required
- (void)RecieptAlertViewdialogButtonWithRemNoSelected:(NSString *)remNo clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
@interface RecieptAlertView : UIView
{
    UIScrollView *scroll;
    UIButton *okButton;
}
-(void)createAlertWithRemmitances:(NSArray *)remArray;
@property (nonatomic, assign) id<RecieptAlertViewDelegate> delegate;
@property (strong, nonatomic) NSMutableArray* selectedChild;
@end
