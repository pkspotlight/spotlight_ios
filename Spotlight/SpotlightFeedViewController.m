//
//  SpotlightFeedViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 9/7/15.
//  Copyright (c) 2015 Spotlight. All rights reserved.
//

#import "SpotlightFeedViewController.h"
#import "Spotlight.h"
#import "SpotlightTableViewCell.h"
#import "SpotlightCollectionViewController.h"
#import "SpotlightMedia.h"
#import "User.h"
#import "SpotlightDataSource.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface SpotlightFeedViewController ()

@end

@implementation SpotlightFeedViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refresh];
    if (!self.dataSource) self.dataSource = [[SpotlightDataSource alloc] init];
    [self.tableView setDataSource:self.dataSource];
    [self.dataSource loadSpotlights:^{
        [self.tableView reloadData];
    }];
}

- (void)refresh:(id)sender {
    [self.dataSource loadSpotlights:^{
        [self.tableView reloadData];
        [sender endRefreshing];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)unwindCreation:(UIStoryboardSegue*)sender {
    [self.dataSource loadSpotlights:^{
        [self.tableView reloadData];
    }];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"SpotlightSegue"]) {
        [(SpotlightCollectionViewController*)[segue destinationViewController] setSpotlight:[(SpotlightTableViewCell*)sender spotlight]];
    }
}


@end
