//
//  SpotlightHeaderCollectionReusableView.h
//  Spotlight
//
//  Created by Peter Kamm on 11/20/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Team;

@interface SpotlightHeaderCollectionReusableView : UICollectionReusableView

- (void)formatHeaderForTeam:(Team*)team;

@property (weak, nonatomic) id delegate;

@end
