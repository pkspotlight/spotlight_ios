//
//  ReorderSpolightImagesTableViewController.h
//  Spotlight
//
//  Created by Aakash Gupta on 8/2/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RefreshTableDelegate <NSObject>

-(void)refreshSpotlightCollectionImages;


@end

@interface ReorderSpolightImagesTableViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) NSMutableArray* mediaSpotlightList;
@property (weak,atomic) id <RefreshTableDelegate> delegate;
@end
