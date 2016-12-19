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
#import "SpotlightCollectionViewController.h"
#import "UIViewController+MediaAddingFunctionality.h"

@interface CreateSpotlightTableViewController ()

@property (strong, nonatomic) Spotlight *spotlight;
@property (weak, nonatomic) IBOutlet UIImageView *teamImageView;
@property (weak, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomContraint;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollviewSpotlight;

@property (weak, nonatomic) IBOutlet UIImageView *teamUserImageView;
@property (weak, nonatomic) IBOutlet UITextField *spotlightTitle;
@property (weak, nonatomic) IBOutlet UITextView *spotlightDescription;

@property (copy) void (^completion)(void);
@property (strong, nonatomic) UIImagePickerController* imagePickerController;



@end

@implementation CreateSpotlightTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.teamNameLabel setText:self.team.teamName];
    self.spotlight = [Spotlight object];
    
    [self.teamUserImageView.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.4].CGColor];
    [self.teamUserImageView.layer setCornerRadius:5];
    [self.teamUserImageView.layer setBorderWidth:2];

    _spotlightTitle.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:146.0/255.0f green:146.0/255.0f blue:146.0/255.0f alpha:1.0]}];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"BackImage"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked:)];
    
    self.navigationItem.leftBarButtonItem = barButton;
    
    self.navigationItem.title = @"Create Spotlight";
    
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
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyBoard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyBoard:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed:(id)sender {
    if(_isFromTeamdetail){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (IBAction)backButtonClicked:(UIButton*)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark: Notification For Showing keyboard

-(void)showKeyBoard:(NSNotification *)notification{
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:keyboardSize.height forKey:@"size"];
    self.bottomContraint.constant = keyboardSize.height ;
    [self.view layoutIfNeeded];
    
}

#pragma mark: Notification For Hiding keyboard

-(void)hideKeyBoard:(NSNotification *)notification{
    self.bottomContraint.constant = 0;
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
            [hud hide:YES];
            __weak id tempSelf = self;
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Spotlight Created!"
                                                                           message:@"Would you like to add photos or videos now?  You can also always add them later."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [tempSelf addMediaButtonPressedCompletion:^{
                    [tempSelf finishSaveProcess];
                }];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"No Thanks" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [tempSelf finishSaveProcess];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

- (void)finishSaveProcess {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
    if(_isFromTeamdetail){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
//            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            SpotlightCollectionViewController *spotLightCollection = [storyboard instantiateViewControllerWithIdentifier:@"SpotLightCollectionView"];
//            [spotLightCollection setSpotlight:self.spotlight];
//            [self.navigationController presentViewController:spotLightCollection animated:YES completion:nil];
        }];
    }

}

- (void)dismissView:(MBProgressHUD*)hud {
    [hud hide:YES afterDelay:1.5];
    if(_isFromTeamdetail){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn:");
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    
    if(range.length + range.location > textView.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return newLength <= 120;
}

@end
