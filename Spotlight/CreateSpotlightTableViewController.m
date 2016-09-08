//
//  CreateSpotlightTableViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 11/20/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "CreateSpotlightTableViewController.h"
#import "Spotlight.h"
#import "SpotlightMedia.h"
#import "Team.h"
#import "User.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MBProgressHUD.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface CreateSpotlightTableViewController ()

@property (strong, nonatomic) Spotlight *spotlight;
@property (weak, nonatomic) IBOutlet UIImageView *teamImageView;
@property (weak, nonatomic) IBOutlet UILabel *teamNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *teamUserImageView;
@property (weak, nonatomic) IBOutlet UITextField *spotlightTitle;
@property (weak, nonatomic) IBOutlet UITextView *spotlightDescription;

@end

@implementation CreateSpotlightTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.teamNameLabel setText:self.team.teamName];
    self.spotlight = [Spotlight object];
      _spotlightTitle.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.teamUserImageView.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.4].CGColor];
    [self.teamUserImageView.layer setCornerRadius:5];
    [self.teamUserImageView.layer setBorderWidth:2];

        [self.teamImageView cancelImageRequestOperation];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.team.teamLogoMedia.thumbnailImageFile.url]];
    [self.teamImageView
     setImageWithURLRequest:request
     placeholderImage:nil
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
         [self.teamImageView setImage:image];
         [self.teamUserImageView setImage:image];

     } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
         NSLog(@"fuck thumbnail failure");
     }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed:(id)sender {
    if(_isFromTeamdetail)
        
        [self.navigationController popViewControllerAnimated:YES];
    
    else
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
}

- (IBAction)saveButtonPressed:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Creating Spotlight..."];
    User* user = [User currentUser];
    PFRelation *participantRelation = [self.spotlight relationForKey:@"creator"];
    [participantRelation addObject:user];
    [self.spotlight.moderators addObject:user];
    [self.spotlight setTeam:self.team];
    self.spotlight.spotlightTitle = self.spotlightTitle.text;
    self.spotlight.spotlightDescription = self.spotlightDescription.text;
    [self.spotlight setCreatorName:[NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName]];
    [self.spotlight saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
         [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
        }
        if(_isFromTeamdetail)
       
            [self.navigationController popViewControllerAnimated:YES];
        
        else
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    
    
}

- (void)dismissView:(MBProgressHUD*)hud {
    [hud hide:YES afterDelay:1.5];
    if(_isFromTeamdetail)
        
        [self.navigationController popViewControllerAnimated:YES];
    
    else
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn:");
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 1;
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CreateSpotlightButtonCell" forIndexPath:indexPath];
//    
//    return cell;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self saveButtonPressed:nil];
//}

@end
