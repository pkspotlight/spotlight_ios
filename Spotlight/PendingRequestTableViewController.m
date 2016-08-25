//
//  PendingRequestTableViewController.m
//  Spotlight
//
//  Created by Aakash Gupta on 7/21/16.
//  Copyright © 2016 Spotlight. All rights reserved.
//

#import "PendingRequestTableViewController.h"
#import "Parse.h"
#import "User.h"
#import "Child.h"
#import "TeamRequest.h"
#import <MBProgressHUD.h>
@interface PendingRequestTableViewController ()
@property (strong, nonatomic) NSMutableArray *requestArray;
@property (strong, nonatomic) NSMutableArray *requestFriendArray;
@end



@implementation PendingRequestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _requestArray = [[NSMutableArray alloc]init];
    _requestFriendArray = [[NSMutableArray alloc]init];

      [self fetchRequest];
    
}


-(void)fetchRequest{
    
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Loading..."];
    PFQuery *spotlightQuery = [PFQuery queryWithClassName:@"TeamRequest"];
    [spotlightQuery whereKey:@"admin" equalTo:[User currentUser]];
    
    [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
       
//        [self.tableView reloadData];
        if(objects.count > 0)
        {
            NSMutableArray *array = [NSMutableArray new];
            for(TeamRequest *request in objects)
            {
                
                
                
                if((request.requestState.intValue == reqestStatePending))
                {
                    if([request.type intValue]==1 || [request.type intValue]==3){
                    [_requestArray addObject:request];
                    
                    [array addObject:request];
                         [self.tableView reloadData];
                    }
                    
                    else if([request.type intValue]==2){
                        [_requestFriendArray addObject:request];
                        
                        [array addObject:request];
                        [self.tableView reloadData];
                    }
                }
                
               
                
            }
            [hud hide:YES];
            
            
        }
        else{
          [hud hide:YES];
        }
        
        
        
        for(TeamRequest *request in objects)
        {
            [request.team fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                //   NSString *data =[NSString stringWithFormat:@"%@       %@",request.admin.firstName,request.user.firstName];
                
               
            }];
            
            
            
        }
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section==0)
    {
        return _requestArray.count;
    }
    else{
        return _requestFriendArray.count;
    }
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return nil;
    } else {
        // return your normal return
        if(section == 0)
            return @"Team Request";
        else
            return @"Friend Request";
    }
   
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PendingRequestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pendingRequest" forIndexPath:indexPath];
   
    
    if (indexPath.section==0) {
        TeamRequest* request = self.requestArray[indexPath.row];
        [cell setData:request.nameOfRequester teamName:request.teamName fromUser:request.user forChild:request.child isChild:request.isChild.boolValue withType:request.type];

    
    }
    else {
        TeamRequest* request = self.requestFriendArray[indexPath.row];
        [cell setData:request.nameOfRequester teamName:request.teamName fromUser:request.user forChild:request.child isChild:request.isChild.boolValue withType:request.type];

    }
    
    
    cell.acceptButton.tag = 1001;
    cell.rejectButton.tag = 1002;
    [cell.acceptButton addTarget:self action:@selector(requestAction:) forControlEvents:UIControlEventTouchUpInside];
     [cell.rejectButton addTarget:self action:@selector(requestAction:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}



-(void)requestAction:(UIButton *)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(PendingRequestTableViewCell *)sender.superview.superview];
    TeamRequest* request;
    if(indexPath.section == 0){
       request    = self.requestArray[indexPath.row];
        
    }
    else{
        request = self.requestFriendArray[indexPath.row];
    }
  
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Please Wait..."];
   
    
    
    if(sender.tag == 1001){
            
        
        request.requestState = [NSNumber numberWithInt:requestStateAccepted];
        
        if([request.type intValue]==3){
            
            [[User currentUser] followTeamWithBlockCallback:request.team completion:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotLightRefersh" object:nil];
                    
                    [request deleteInBackground];
                        if(indexPath.section == 0){
                            [_requestArray removeObjectAtIndex:indexPath.row];
                        }
                        else{
                            [_requestFriendArray removeObjectAtIndex:indexPath.row];
                        }
                        
                        if(_requestArray.count==0&&_requestFriendArray.count == 0){
                            [self.navigationController popViewControllerAnimated:YES];
                            
                        }
                        else{
                            
                            [self.tableView reloadData];
                        }
                    }
                    else
                    {
                        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:@"Unable to accept the request. Please check your network and try again." preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            
                        }];
                        [controller addAction:action];
                        [self.navigationController presentViewController:controller animated:YES completion:nil];
                    }
                  

                    
               
            }];
            [hud hide:YES];
        }
        else if([request.type intValue]==1){
        
          UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Do you want to associate this user Spectator or Participant" preferredStyle:UIAlertControllerStyleAlert];
        
                    [alertController addAction:[UIAlertAction actionWithTitle:@"Spectator" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [request.team fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                            
                            if(!error){
                                if(!request.team.spectatorsArray){
                                    request.team.spectatorsArray = [NSMutableArray new];
                                }
                            [request.team.spectatorsArray addObject:request.user.objectId];
                            
                            [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                if(succeeded){
                                    
                                    
                                    if(indexPath.section == 0){
                                        [_requestArray removeObjectAtIndex:indexPath.row];
                                    }
                                    else{
                                        [_requestFriendArray removeObjectAtIndex:indexPath.row];
                                    }
                                    
                                    if(_requestArray.count==0&&_requestFriendArray.count == 0){
                                        [self.navigationController popViewControllerAnimated:YES];
                                        
                                    }
                                    else{
                                        
                                        [self.tableView reloadData];
                                    }
                                }
                                else
                                {
                                    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:@"Unable to accept the request. Please check your network and try again." preferredStyle:UIAlertControllerStyleAlert];
                                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                        
                                    }];
                                    [controller addAction:action];
                                    [self.navigationController presentViewController:controller animated:YES completion:nil];
                                }
                                [hud hide:YES];
                            }];
                            }
                            
                            else{
                                UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:@"Unable to accept the request. Please check your network and try again." preferredStyle:UIAlertControllerStyleAlert];
                                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                    
                                }];
                                [controller addAction:action];
                                [self.navigationController presentViewController:controller animated:YES completion:nil];
                            }
                        }];
                       
                        
        
        
        
        
                    }]];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"Participant" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                        [request.team fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                            
                            if(!error){
                                while( [request.team.spectatorsArray containsObject:request.user.objectId])
                                {
                                    [request.team.spectatorsArray removeObject:request.user.objectId];
                                }
                               
                                
                                [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                    if(succeeded){
                                        
                                        
                                        if(indexPath.section == 0){
                                            [_requestArray removeObjectAtIndex:indexPath.row];
                                        }
                                        else{
                                            [_requestFriendArray removeObjectAtIndex:indexPath.row];
                                        }
                                        
                                        if(_requestArray.count==0&&_requestFriendArray.count == 0){
                                            [self.navigationController popViewControllerAnimated:YES];
                                            
                                        }
                                        else{
                                            
                                            [self.tableView reloadData];
                                        }
                                    }
                                    else
                                    {
                                        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:@"Unable to accept the request. Please check your network and try again." preferredStyle:UIAlertControllerStyleAlert];
                                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                            
                                        }];
                                        [controller addAction:action];
                                        [self.navigationController presentViewController:controller animated:YES completion:nil];
                                    }
                                    [hud hide:YES];
                                }];
                            }
                            
                            else{
                                UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:@"Unable to accept the request. Please check your network and try again." preferredStyle:UIAlertControllerStyleAlert];
                                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                    
                                }];
                                [controller addAction:action];
                                [self.navigationController presentViewController:controller animated:YES completion:nil];
                            }
                        }];
                        
                        
                        
                        
                        [hud hide:YES];
                    }]];
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        [self presentViewController:alertController animated:YES completion:nil];
                    });
        
                }

        else if([request.type intValue]==2){
            [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded){
                    
                    
                    if(indexPath.section == 0){
                        [_requestArray removeObjectAtIndex:indexPath.row];
                    }
                    else{
                        [_requestFriendArray removeObjectAtIndex:indexPath.row];
                    }
                    
                    if(_requestArray.count==0&&_requestFriendArray.count == 0){
                        [self.navigationController popViewControllerAnimated:YES];
                        
                    }
                    else{
                        
                        [self.tableView reloadData];
                    }
                }
                else
                {
                    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:@"Unable to accept the request. Please check your network and try again." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    [controller addAction:action];
                    [self.navigationController presentViewController:controller animated:YES completion:nil];
                }
                [hud hide:YES];
            }];
            
            

        }
    
    }
    
       // }
    
    
    
    
        //NSLog(@"%d",indexPath.row);
    
    else if(sender.tag == 1002){
        
        [request deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded){
              
                if(indexPath.section == 0){
                    [_requestArray removeObjectAtIndex:indexPath.row];
                }
                else{
                    [_requestFriendArray removeObjectAtIndex:indexPath.row];
                }
                if(_requestArray.count==0&&_requestFriendArray.count == 0){
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }
                else{
                    
                    [self.tableView reloadData];
                }

            
            }
            
            [hud hide:YES];
        }];

        
    }

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
