//
//  ReorderSpolightImagesTableViewController.m
//  Spotlight
//
//  Created by Aakash Gupta on 8/2/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import "ReorderSpolightImagesTableViewController.h"
#import <Parse/Parse.h>
#import "User.h"
#import "Child.h"
#import "TeamRequest.h"
#import <MBProgressHUD.h>
#import "ReorderImagesTableViewCell.h"
@interface ReorderSpolightImagesTableViewController ()
@property (strong, nonatomic) NSMutableArray *requestArray;

@end

@implementation ReorderSpolightImagesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    self.editing = YES;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:(UIBarButtonSystemItemDone) target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = barButton;
     // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _mediaSpotlightList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     ReorderImagesTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"reorderImages" forIndexPath:indexPath];
    
    [cell setDataSpotlight:[self.mediaSpotlightList objectAtIndex:indexPath.row]];
//    TeamRequest* request = self.requestArray[indexPath.row];
//    [cell setData:request.nameOfRequester teamName:request.teamName fromUser:request.user forChild:request.child isChild:request.isChild.boolValue];
//    
//    cell.acceptButton.tag = 1001;
//    cell.rejectButton.tag = 1002;
//    [cell.acceptButton addTarget:self action:@selector(requestAction:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.rejectButton addTarget:self action:@selector(requestAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{   SpotlightMedia *media= self.mediaSpotlightList[fromIndexPath.row];
    [self.mediaSpotlightList removeObjectAtIndex:fromIndexPath.row];
    [self.mediaSpotlightList insertObject:media atIndex:toIndexPath.row]; // A method of your own to make new positions persistent
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


-(void)save{
  
    double timestamp = [[NSDate date] timeIntervalSince1970] - [self.mediaSpotlightList count];
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:YES];
    [hud setLabelText:@"Please Wait..."];

    for(SpotlightMedia *media in self.mediaSpotlightList){
        timestamp = timestamp+1;
        media.timeStamp = timestamp;
    }
    [MediaObject saveAllInBackground:self.mediaSpotlightList block:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            [hud hide:YES];
            [self.delegate refreshSpotlightCollectionImages];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
