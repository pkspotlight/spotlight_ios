//
//  RecieptAlertView.m
//  APPvantage
//
//  Created by Yashika Garg on 01/06/16.
//  Copyright © 2016 Algoworks Technologies Pvt. Ltd. All rights reserved.
//

#import "RecieptAlertView.h"
#import "remittanceSelectionView.h"
#import "Child.h"
#define appDel ((AppDelegate *)[UIApplication sharedApplication].delegate)
const static CGFloat kCustomIOS7AlertViewDefaultButtonHeight       = 50;
const static CGFloat kCustomIOS7AlertViewDefaultButtonSpacerHeight = 1;

@implementation RecieptAlertView
-(void)createAlertWithRemmitances:(NSArray *)remArray
{
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    
    UIView *dialogContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
   
    
    self.selectedChild = [NSMutableArray new];
    [self.selectedChild removeAllObjects];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, dialogContainer.frame.size.width - 20, 0)];
    titleLabel.text = @"Select a Child to associate with team";
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel sizeToFit];

    [dialogContainer addSubview:titleLabel];
    
    float dialogHeight = titleLabel.frame.origin.y + titleLabel.frame.size.height;
    dialogHeight += 10;
    scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, dialogHeight, titleLabel.frame.size.width, 0)];
    scroll.clipsToBounds = YES;
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.showsVerticalScrollIndicator = NO;
    int YOffset = 0;
    NSMutableArray *displayNameArray = [NSMutableArray new];
    [displayNameArray removeAllObjects];
    for (Child* child in remArray){
        NSString *displayName =  [child displayName];
        [displayNameArray addObject:displayName];
    }
    
    for(int i = 0 ; i < remArray.count ; i ++)
    {
        remittanceSelectionView *view = [[remittanceSelectionView alloc] init];
        view.childSelected = remArray[i];
        view.frame = CGRectMake(0, YOffset, scroll.frame.size.width, 30);
        view.remButton = [UIButton buttonWithType:UIButtonTypeCustom];
        view.remButton.frame = CGRectMake(view.frame.size.width - 20, (view.frame.size.height - 20 )/2.0,20,20);
        [view.remButton setImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];
        [view.remButton setImage:[UIImage imageNamed:@"Checked"] forState:UIControlStateSelected];
        
        view.remButton.userInteractionEnabled = NO;
        
        [view addSubview:view.remButton];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, view.frame.size.width - 30, 30)];
        label.text = displayNameArray[i];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentLeft;
        [view addSubview:label];
        
        UITapGestureRecognizer *tapGes  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(remButtonClicked:)];
        [view addGestureRecognizer:tapGes];
        YOffset = view.frame.origin.y + view.frame.size.height;
        [scroll addSubview:view];
    }
    
    
    
    
    CGRect rect = scroll.frame;
   if(YOffset > 300)
   {
    rect.size.height = 300;
   }
     else
    {
    rect.size.height = YOffset;

   }
    scroll.frame = rect;
    [scroll setContentSize:CGSizeMake(0, YOffset)];
    [dialogContainer addSubview:scroll];
    dialogHeight += scroll.frame.size.height;
    
    dialogHeight += 10;
    UILabel *titleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(10, dialogHeight, dialogContainer.frame.size.width - 20, 0)];
    titleLabel1.text = @"";
    titleLabel1.textAlignment = NSTextAlignmentLeft;
    titleLabel1.numberOfLines = 0;
    [titleLabel1 sizeToFit];
    [dialogContainer addSubview:titleLabel1];
    dialogHeight += titleLabel1.frame.size.height;
    
    [dialogContainer addSubview:titleLabel];
    // There is a line above the button
  
    
    dialogHeight += 60;
    
    
    rect = dialogContainer.frame;
    rect.size.height = dialogHeight;
    dialogContainer.frame = rect;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, dialogContainer.bounds.size.height - kCustomIOS7AlertViewDefaultButtonHeight - kCustomIOS7AlertViewDefaultButtonSpacerHeight, dialogContainer.bounds.size.width, kCustomIOS7AlertViewDefaultButtonSpacerHeight)];
    lineView.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
    [dialogContainer addSubview:lineView];
    // ^^^
    
    // Add the custom container if there is any
  //  [dialogContainer addSubview:containerView];
    
    // Add the buttons too
    [self addButtonsToView:dialogContainer WithButtonArray:@[@"Cancel",@"Ok"]];
    [self addSubview:dialogContainer];
    dialogContainer.center = self.center;
    
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = dialogContainer.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0f] CGColor],
                       nil];
    
    CGFloat cornerRadius = 7.0;
    gradient.cornerRadius = cornerRadius;
    [dialogContainer.layer insertSublayer:gradient atIndex:0];
    
    dialogContainer.layer.cornerRadius = cornerRadius;
    dialogContainer.layer.borderColor = [[UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f] CGColor];
    dialogContainer.layer.borderWidth = 1;
    dialogContainer.layer.shadowRadius = cornerRadius + 5;
    dialogContainer.layer.shadowOpacity = 0.1f;
    dialogContainer.layer.shadowOffset = CGSizeMake(0 - (cornerRadius+5)/2, 0 - (cornerRadius+5)/2);
    dialogContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    dialogContainer.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:dialogContainer.bounds cornerRadius:dialogContainer.layer.cornerRadius].CGPath;
    
    
    [[[UIApplication sharedApplication].delegate window] addSubview:self];
    
}

- (void)addButtonsToView: (UIView *)container WithButtonArray:(NSArray *)buttonTitles
{
    if (buttonTitles==NULL) { return; }
    
    CGFloat buttonWidth = container.bounds.size.width / [buttonTitles count];
    
    for (int i=0; i<[buttonTitles count]; i++) {
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [closeButton setFrame:CGRectMake(i * buttonWidth, container.bounds.size.height - kCustomIOS7AlertViewDefaultButtonHeight, buttonWidth, kCustomIOS7AlertViewDefaultButtonHeight)];
        
        [closeButton addTarget:self action:@selector(customIOS7dialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        closeButton.tag = i;
        closeButton.layer.borderColor=[[UIColor lightGrayColor] CGColor] ;
        closeButton.layer.borderWidth=0.5f;
        [closeButton setTitle:[buttonTitles objectAtIndex:i] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.5f] forState:UIControlStateHighlighted];
             [container addSubview:closeButton];
        if(i == 1)
        {
            closeButton.alpha = 0.3;
            closeButton.userInteractionEnabled = NO;
            okButton  = closeButton;
        }
        
    }
}


-(void)remButtonClicked:(UITapGestureRecognizer *)tapGes
{
    remittanceSelectionView *view  = (remittanceSelectionView *)tapGes.view;
    
    view.remButton.selected = !view.remButton.selected;
    
    okButton.alpha = 1.0;
    okButton.userInteractionEnabled = YES;
    
}


-(NSMutableArray *)getSelectedRemNumber
{
    
    for(remittanceSelectionView *remView in scroll.subviews)
    {
        if([remView isKindOfClass:[remittanceSelectionView class]])
        {
            if(remView.remButton.isSelected)
            {
                [self.selectedChild addObject:remView.childSelected];
            }
        }
    }
    
    return self.selectedChild;
}

- (IBAction)customIOS7dialogButtonTouchUpInside:(UIButton*)sender
{
    
    if(sender.tag == 0){
       // NSMutableArray *childSelectedArray = [self getSelectedRemNumber];
        
        [self.delegate RecieptAlertViewdialogButtonWithChildSelected:@[].mutableCopy];
        [self removeFromSuperview];

    }
    else  if(sender.tag == 1){
        
        NSMutableArray *childSelectedArray = [self getSelectedRemNumber];
        [self.delegate RecieptAlertViewdialogButtonWithChildSelected:childSelectedArray];
          [self removeFromSuperview];
    }
        }




@end
