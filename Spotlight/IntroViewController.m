//
//  IntroViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 9/10/15.
//  Copyright (c) 2015 Spotlight. All rights reserved.
//

#import "IntroViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface IntroViewController ()

@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.signupButton.layer setCornerRadius:7];
    [self.loginButton.layer setCornerRadius:7];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
