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
#import <Parse.h>


@interface SignUpTableViewController ()

@property (strong, nonatomic) NSMutableDictionary *pendingInputDict;

@end

@implementation SignUpTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pendingInputDict = [[NSMutableDictionary alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SignUpInputTableViewCell *cell;
    switch (indexPath.row) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"EmailCell" forIndexPath:indexPath];
            [cell setFieldName:@"email"];
            break;
            
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"PasswordCell" forIndexPath:indexPath];
            [cell setFieldName:@"password"];
            break;
            
        default:
            break;
    }
    [cell setDelegate:self];
    return cell;
}

- (void)loadMainTabBar {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainTabBarController *mainTabBarController = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
    [[UIApplication sharedApplication].delegate.window setRootViewController:mainTabBarController];

}

- (IBAction)createAccountButtonPressed:(id)sender {
    
    if (self.pendingInputDict[@"email"] &&
        [self.pendingInputDict[@"email"] length] > 4 &&
        self.pendingInputDict[@"password"] &&
        [self.pendingInputDict[@"password"] length] > 4) {

    PFUser *user = [PFUser user];
    user.username = self.pendingInputDict[@"email"];
    user.password = self.pendingInputDict[@"password"];
   // user.email = @"email@example.com";
    
    // other fields can be set just like with PFObject
   // user[@"phone"] = @"415-392-0202";
    
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
    if (self.pendingInputDict[@"email"] &&
        [self.pendingInputDict[@"email"] length] > 4 &&
        self.pendingInputDict[@"password"] &&
        [self.pendingInputDict[@"password"] length] > 4) {
    [PFUser logInWithUsernameInBackground:self.pendingInputDict[@"email"]
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

- (void)inputTextFieldCell:(SignUpInputTableViewCell *)cell didChangeToValue:(NSString *)text {
    
    self.pendingInputDict[cell.fieldName] = text;
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
