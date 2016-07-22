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
@interface PendingRequestTableViewController ()
@property (strong, nonatomic) NSMutableArray *requestArray;

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
      [self fetchRequest];
    
}


-(void)fetchRequest{
    
    
    
    PFQuery *spotlightQuery = [PFQuery queryWithClassName:@"TeamRequest"];
    [spotlightQuery whereKey:@"admin" equalTo:[User currentUser]];
    
    [spotlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
       
//        [self.tableView reloadData];
        if(objects.count > 0)
        {
            NSMutableArray *array = [NSMutableArray new];
            for(TeamRequest *request in objects)
            {
                if(request.user.objectId != request.admin.objectId)
                {
                    [_requestArray addObject:request];
                     [self.tableView reloadData];
                    [array addObject:request];
                }
                
            }
         
            
            
        }
        else{
         
        }
        
//        for(TeamRequest *request in objects)
//        {
//            [request.admin fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
//                //   NSString *data =[NSString stringWithFormat:@"%@       %@",request.admin.firstName,request.user.firstName];
//                
//                NSLog(@"%@",request.admin.firstName);
//            }];
//            
//            
//            
//        }
        
    }];
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

    return _requestArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PendingRequestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pendingRequest" forIndexPath:indexPath];
   TeamRequest* request = self.requestArray[indexPath.row];
    [cell setData:request.nameOfRequester teamName:request.teamName fromUser:request.user forChild:request.child];
    
    cell.acceptButton.tag = 1001;
    cell.rejectButton.tag = 1002;
    [cell.acceptButton addTarget:self action:@selector(requestAction:) forControlEvents:UIControlEventTouchUpInside];
     [cell.rejectButton addTarget:self action:@selector(requestAction:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}



-(void)requestAction:(UIButton *)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(PendingRequestTableViewCell *)sender.superview.superview];
    TeamRequest* request = self.requestArray[indexPath.row];
    
    if(sender.tag == 1001){
        
        
        [request.team fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            
            if(request.user){
                [request.user followTeam:request.team completion:^{
                   
                    [request deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if(succeeded){
                            
                            [_requestArray removeObjectAtIndex:indexPath.row];
                            if(_requestArray.count==0){
                                [self.navigationController popViewControllerAnimated:YES];
                         
                            }
                            else{
                                   [self.tableView reloadData];
                            }
                        }
                    }];


                
                }];
            }
            else{
                
                 [request.child fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                
                     [request.child followTeam:request.team completion:^{
                         
                        
                         [request deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                             if(succeeded){
                                
                                 [_requestArray removeObjectAtIndex:indexPath.row];
                                 if(_requestArray.count==0){
                                     [self.navigationController popViewControllerAnimated:YES];
                                     
                                 }
                                 else{
                                     [self.tableView reloadData];
                                 }                             }
                         }];
                     }];
                     
                 }];
            }

            
          
            
            NSLog(@"%@",request.admin.firstName);
        }];

        
        
        
        
        
        //NSLog(@"%d",indexPath.row);
    }
    else if(sender.tag == 1002){
        
        [request deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded){
                [_requestArray removeObjectAtIndex:indexPath.row];
                if(_requestArray.count==0){
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }
                else{
                    [self.tableView reloadData];
                }
            
            }
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
