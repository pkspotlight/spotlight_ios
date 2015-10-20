//
//  SpotlightTableViewController.m
//  Spotlight
//
//  Created by Peter Kamm on 10/20/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "SpotlightTableViewController.h"
#import "SpotlightMediaTableViewCell.h"

@interface SpotlightTableViewController ()

@property (strong, nonatomic) NSArray* mediaList;

@end

@implementation SpotlightTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.spotlight allMedia:^(NSArray *media, NSError *error) {
        self.mediaList = media;
        [self.tableView reloadData];
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
    return [self.mediaList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SpotlightMediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SpotlightMediaTableViewCell" forIndexPath:indexPath];
    [cell formatWithSpotlightMedia:self.mediaList[indexPath.row]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Create browser (must be done each time photo browser is
    // displayed. Photo browser objects cannot be re-used)
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    // Set options
    browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
    browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    browser.autoPlayOnAppear = YES; // Auto-play first video

    // Optionally set the current visible photo before displaying
    [browser setCurrentPhotoIndex:indexPath.row];
    
    // Present
    [self.navigationController pushViewController:browser animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.mediaList.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.mediaList.count) {
        return [self mwphotoForSpotlightMedia:[self.mediaList objectAtIndex:index]];
    }
    return nil;
}

- (MWPhoto*)mwphotoForSpotlightMedia:(SpotlightMedia*)media {
    
    if (media.isVideo) {
        MWPhoto *video = [MWPhoto photoWithURL:[NSURL URLWithString:media.thumbnailImageFile.url]];
        video.videoURL = [NSURL URLWithString:media.mediaFile.url];
        return video;
    } else {
        return [MWPhoto photoWithURL:[NSURL URLWithString:media.mediaFile.url]];
    }
}

@end
