//
//  IntroViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 9/10/15.
//  Copyright (c) 2015 Spotlight. All rights reserved.
//

#import "IntroViewController.h"
#import "SignUpTableViewController.h"
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"LoginSegueIdentifier"]) {
        [(SignUpTableViewController*)[segue destinationViewController] setIsLoginScreen:YES];
    } else {
        [(SignUpTableViewController*)[segue destinationViewController] setIsLoginScreen:NO];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
