//
//  TermsOfServiceViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 5/4/17.
//  Copyright © 2017 Spotlight. All rights reserved.
//

#import "TermsOfServiceViewController.h"

@interface TermsOfServiceViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation TermsOfServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http:www.myspotlight.me/terms-of-use/"]]];
                                                       
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)iAgreedButtonPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"hasAgreedToTOS"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
