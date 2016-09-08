//
//  SpotlightTableViewCell.m
//  Spotlight
//
//  Created by Peter Kamm on 10/19/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import "SpotlightTableViewCell.h"
#import "Team.h"
#import "User.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface SpotlightTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *spotlightCreatedTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UILabel *createdByLabel;
@property (weak, nonatomic) IBOutlet UILabel *spotlightDescriptionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *teamImageView;

@end

@implementation SpotlightTableViewCell



- (void)awakeFromNib {
    // Initialization code
    
    self.mainImageView.layer.cornerRadius = 5;
    [self.mainImageView.layer setBorderColor:[UIColor clearColor].CGColor];
    [self.mainImageView.layer setBorderWidth:1];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)formatForSpotlight:(Spotlight*)spotlight dateFormat:(NSDateFormatter*)dateFormatter {
    _spotlight = spotlight;
    
    _isEditingAllowed = NO;
    PFQuery* moderatorQuery = [spotlight.moderators query];
    [moderatorQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        for (User* user in objects) {
            if ([user.objectId isEqualToString:[[User currentUser] objectId]]) {
                
                _isEditingAllowed = true;
            }
        }
    }];
    
    
    Team* team = self.spotlight.team;
    [self.mainImageView setImage:nil];
    [self.mainImageView cancelImageRequestOperation];
    [self.titleLabel setText:spotlight.team.teamName];
    
//    [self.titleLabel setText:[NSString stringWithFormat:@"%@ %@ - Grade %@", team.teamName, team.sport, team.grade]];
//
    NSDate* referencedate = self.spotlight.createdAt;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *spotlightTime = [NSString stringWithFormat:@"%@",[formatter stringFromDate:referencedate]];
    
    NSTimeInterval timestampSmall = [formatter dateFromString:spotlightTime].timeIntervalSince1970;
   // NSTimeInterval spotlightTimeInterval = [[NSDate date] timeIntervalSinceDate:referencedate];
    long timeStamp = (long)[[NSDate date] timeIntervalSince1970];
    if([_spotlight.spotlightDescription length]<=0){
        _lblHeightConstraint.constant = 10;
    }
    else{
//        [NSLayoutConstraint deactivateConstraints:@[_lblHeightConstraint]];
        _lblHeightConstraint.constant = 50;
           }
    self.spotlightDescriptionLabel.text = _spotlight.spotlightDescription;
    NSString *getTime = [self timeforTimeDiffernceBetweenBigger:timeStamp andsmallTime:timestampSmall];
    


    self.spotlightCreatedTimeLabel.text = getTime;
    [self.createdByLabel setText:[NSString stringWithFormat:@"by %@", self.spotlight.creatorName]];
    [spotlight allThumbnailUrls:^(NSArray *urls, NSError *error) {
        if (urls && !error) {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[urls firstObject]]];
            [self.mainImageView
             setImageWithURLRequest:request
             placeholderImage:[UIImage imageNamed:@"spotlightPalceholder"]
             success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                 [self.mainImageView setImage:image];
             } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                 NSLog(@"fuck thumbnail failure");
             }];
        }
    }];
    
    [self.teamImageView.layer setCornerRadius:self.teamImageView.bounds.size.width/2];
    [self.teamImageView.layer setBorderWidth:3];
    [self.teamImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.teamImageView setClipsToBounds:YES];
    [self.teamImageView cancelImageRequestOperation];

    [spotlight.team.teamLogoMedia fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[(TeamLogoMedia*)object thumbnailImageFile].url]];
        [self.teamImageView
         setImageWithURLRequest:request
         placeholderImage:[UIImage imageNamed:@"UserPlaceholder"]
         success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
             [self.teamImageView setImage:image];
         } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
             NSLog(@"fuck thumbnail failure");
         }];
    }];
}


-(NSString*)timeforTimeDiffernceBetweenBigger:(NSTimeInterval)timeBigger andsmallTime:(NSTimeInterval)smallTime{
  //  NSDate *currentDate = [NSDate date];
    //NSCalendar *calender = [[NSCalendar alloc]init];
    
    
    
    NSInteger differenceInSeconds = (timeBigger - smallTime);
    if(differenceInSeconds <59){
        return @"Just Now";
    }else if (differenceInSeconds>=60){
        NSInteger differenceInMinutes = differenceInSeconds/60;
        if(differenceInMinutes<59){
            return [NSString stringWithFormat:@"%ld mins ago",(long)differenceInMinutes];
        }else if (differenceInMinutes >=60){
            NSInteger differenceInHours = differenceInMinutes/60;
            if(differenceInHours <23){
                return [NSString stringWithFormat:@"%ld hrs ago",(long)differenceInHours];
            }else if(differenceInHours >=24){
                NSInteger differenceInDays = differenceInHours/24;
                NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                [dateformate setDateFormat:@"MMM d, yyyy"]; // Date formater
                NSDate* referencedate = self.spotlight.createdAt;
               
                NSString *spotlightTime = [NSString stringWithFormat:@"%@",[dateformate stringFromDate:referencedate]];

            
                return spotlightTime;

                }
            
            }
            
        }
   
    return nil;
}



@end
