//
//  FriendProfileViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 12/1/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "FriendProfileViewController.h"
#import "SpotlightFeedViewController.h"

@interface FriendProfileViewController()

@property (weak, nonatomic) IBOutlet UIImageView *friendImageView;
@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;

@end

@implementation FriendProfileViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.friendNameLabel setText:self.user.username];
//    [self.]
    
}

//- (void)cycleFromViewController: (UIViewController*) oldVC
//               toViewController: (UIViewController*) newVC {
//    // Prepare the two view controllers for the change.
//    [oldVC willMoveToParentViewController:nil];
//    [self addChildViewController:newVC];
//    
//    // Get the start frame of the new view controller and the end frame
//    // for the old view controller. Both rectangles are offscreen.
//    newVC.view.frame = [self newViewStartFrame];
//    CGRect endFrame = [self oldViewEndFrame];
//    
//    // Queue up the transition animation.
//    [self transitionFromViewController: oldVC toViewController: newVC
//                              duration: 0.25 options:0
//                            animations:^{
//                                // Animate the views to their final positions.
//                                newVC.view.frame = oldVC.view.frame;
//                                oldVC.view.frame = endFrame;
//                            }
//                            completion:^(BOOL finished) {
//                                // Remove the old view controller and send the final
//                                // notification to the new view controller.
//                                [oldVC removeFromParentViewController];
//                                [newVC didMoveToParentViewController:self];
//                            }];
//}

-(BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [(SpotlightFeedViewController*)[segue destinationViewController] setUser:self.user];
}

@end
