//
//  SignUpTableViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 9/9/15.
//  Copyright (c) 2015 Spotlight. All rights reserved.
//

#import "SignUpTableViewController.h"
#import "SpotlightFeedViewController.h"
#import "MainTabBarController.h"
#import "User.h"
#import <Parse.h>


@interface SignUpTableViewController ()

@property (strong, nonatomic) NSMutableDictionary *pendingInputDict;
@property (strong, nonatomic) NSArray* userPropertyArray;
@property (strong, nonatomic) NSArray* userPropertyDisplayArray;

@end

@implementation SignUpTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isLoginScreen) {
        self.userPropertyArray = @[ @"username", @"password"];
        self.userPropertyDisplayArray = @[ @"Username", @"Password"];
    } else {
        self.userPropertyArray = @[ @"email", @"password", @"username"];
        self.userPropertyDisplayArray = @[ @"Email", @"Password", @"Username"];
    }
    self.pendingInputDict = [[NSMutableDictionary alloc] init];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.userPropertyArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FieldEntryTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FieldEntryTableViewCell" forIndexPath:indexPath];
    NSString* attribute = self.userPropertyArray[indexPath.row];
    NSString* inputtedValue = (self.pendingInputDict[attribute]) ? self.pendingInputDict[attribute] : @"";
    [cell formatForAttributeString:self.userPropertyArray[indexPath.row]
                       displayText:self.userPropertyDisplayArray[indexPath.row]
                         withValue:inputtedValue];
    [cell setDelegate:self];
    if ([attribute isEqualToString:@"email"]) {
        [cell setKeyboardType:UIKeyboardTypeEmailAddress];
    }
    
    if ([attribute isEqualToString:@"password"]) {
        [cell setIsSecure:YES];
    }
    
    return cell;
}

- (void)loadMainTabBar {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainTabBarController *mainTabBarController = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
    if([User currentUser].isNew){
        
        
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PendingRequest" object:nil];
    });

    [[UIApplication sharedApplication].delegate.window setRootViewController:mainTabBarController];
    
}

- (IBAction)createAccountButtonPressed:(id)sender {
    
    if (self.pendingInputDict[@"email"] &&
        [self.pendingInputDict[@"email"] length] > 4 &&
        self.pendingInputDict[@"password"] &&
        [self.pendingInputDict[@"password"] length] > 4 &&
        self.pendingInputDict[@"username"] &&
        [self.pendingInputDict[@"username"] length] > 4) {
        
        PFUser *user = [PFUser user];
        user.username = self.pendingInputDict[@"username"];
        user.email = self.pendingInputDict[@"email"];
        user.password = self.pendingInputDict[@"password"];

        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {   // Hooray! Let them use the app now.
                NSLog(@"sweet");
                [self loadMainTabBar];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Nope" message:errorString preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
                NSLog(@"shit, %@",errorString);
            }
        }];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid Username/Password"
                                                                       message:@"Please make sure that you have entered a valid e-mail address and that your password is at least 4 charaters long" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (IBAction)LogInButtonPressed:(id)sender {
    if (self.pendingInputDict[@"username"] &&
        [self.pendingInputDict[@"username"] length] > 4 &&
        self.pendingInputDict[@"password"] &&
        [self.pendingInputDict[@"password"] length] > 4) {
        [User logInWithUsernameInBackground:self.pendingInputDict[@"username"]
                                     password:self.pendingInputDict[@"password"]
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                NSLog(@"sweet");
                                                [self loadMainTabBar];
                                            } else {
                                                NSString *errorString = [error userInfo][@"error"];
                                                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Nope" message:errorString preferredStyle:UIAlertControllerStyleAlert];
                                                [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                                                          style:UIAlertActionStyleCancel
                                                                                        handler:nil]];
                                                [self presentViewController:alert animated:YES completion:nil];
                                                NSLog(@"shit, %@",errorString);
                                            }
                                        }];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid Username/Password"
                                                                       message:@"Please make sure that you have entered a valid e-mail address and that your password is at least 4 charaters long" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Delegate Methods

- (void)accountTextFieldCell:(FieldEntryTableViewCell *)cell didChangeToValue:(NSString *)text {
    self.pendingInputDict[cell.attributeString] = text;
}

- (void)accountTextFieldCellDidReturn:(FieldEntryTableViewCell *)cell {
    NSIndexPath *path = [self indexPathFollowingAttribute:cell.attributeString];
    if (path) {
        FieldEntryTableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        if (cell) {
            [cell focusTextField];
        }
    } else {
        if ([self.view endEditing:NO]) {
            if (self.isLoginScreen) {
                [self LogInButtonPressed:nil];
            }else {
                [self createAccountButtonPressed:nil];
            }
        
        }
    }
}

- (NSIndexPath *)indexPathFollowingAttribute:(NSString*)attribute{
    NSInteger index = [self.userPropertyArray indexOfObject:attribute];
    NSInteger nextIndex = index + 1;
    if (nextIndex < self.userPropertyArray.count) {
        return [NSIndexPath indexPathForRow:nextIndex inSection:0];
    }
    return nil;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
