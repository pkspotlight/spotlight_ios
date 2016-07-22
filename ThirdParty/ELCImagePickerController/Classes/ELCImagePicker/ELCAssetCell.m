//
//  AssetCell.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetCell.h"
#import "ELCAsset.h"

@interface ELCAssetCell ()
{
    float squareSide;
}
@property (nonatomic, strong) NSArray *rowAssets;
@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, strong) NSMutableArray *overlayViewArray;

@end

@implementation ELCAssetCell

//Using auto synthesizers

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	if (self) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
        [self addGestureRecognizer:tapRecognizer];
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:4];
        self.imageViewArray = mutableArray;
        squareSide = 100;

        NSMutableArray *overlayArray = [[NSMutableArray alloc] initWithCapacity:4];
        self.overlayViewArray = overlayArray;
	}
	return self;
}

- (void)setAssets:(NSArray *)assets
{
    self.rowAssets = assets;
	for (UIImageView *view in _imageViewArray) {
        [view removeFromSuperview];
	}
    for (UIImageView *view in _overlayViewArray) {
        [view removeFromSuperview];
	}
    //set up a pointer here so we don't keep calling [UIImage imageNamed:] if creating overlays
    UIImage *overlayImage = nil;
    for (int i = 0; i < [_rowAssets count]; ++i) {

        ELCAsset *asset = [_rowAssets objectAtIndex:i];

        if (i < [_imageViewArray count]) {
            UIImageView *imageView = [_imageViewArray objectAtIndex:i];
            imageView.image = [UIImage imageWithCGImage:asset.asset.thumbnail];
            for(UIView *subview in imageView.subviews)
                [subview removeFromSuperview];
            
            if ([[asset.asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                // asset is a video
                
                
                UIImageView *videoIcon = [[UIImageView alloc] initWithFrame:CGRectMake((squareSide - 30)/2.0, (squareSide - 30)/2.0, 30, 30)];
                videoIcon.image = [UIImage imageNamed:@"video_Icon"];
                
                [imageView addSubview:videoIcon];
            }
           
            
        } else {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:asset.asset.thumbnail]];
            [_imageViewArray addObject:imageView];
            
            for(UIView *subview in imageView.subviews)
                [subview removeFromSuperview];

            
            if ([[asset.asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                // asset is a video
                
                
                 UIImageView *videoIcon = [[UIImageView alloc] initWithFrame:CGRectMake((squareSide - 30)/2.0, (squareSide - 30)/2.0, 30, 30)];
                videoIcon.image = [UIImage imageNamed:@"video_Icon"];
                
                [imageView addSubview:videoIcon];
            }
        }
        
        if (i < [_overlayViewArray count]) {
            UIImageView *overlayView = [_overlayViewArray objectAtIndex:i];
            overlayView.hidden = asset.selected ? NO : YES;
        } else {
            if (overlayImage == nil) {
                overlayImage = [UIImage imageNamed:@"Overlay.png"];
            }
            
            
            
            UIImageView *overlayView = [[UIImageView alloc] initWithImage:overlayImage];
            [_overlayViewArray addObject:overlayView];
            overlayView.hidden = asset.selected ? NO : YES;
        }
    }
}

- (void)cellTapped:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint point = [tapRecognizer locationInView:self];
    CGFloat totalWidth = self.rowAssets.count * squareSide + (self.rowAssets.count - 1) * 4;
    CGFloat startX = (self.bounds.size.width - totalWidth) / 2;
    
	CGRect frame = CGRectMake(startX, 2, squareSide, squareSide);
	
	for (int i = 0; i < [_rowAssets count]; ++i) {
        if (CGRectContainsPoint(frame, point)) {
            ELCAsset *asset = [_rowAssets objectAtIndex:i];
            asset.selected = !asset.selected;
            UIImageView *overlayView = [_overlayViewArray objectAtIndex:i];
            overlayView.hidden = !asset.selected;
            break;
        }
        frame.origin.x = frame.origin.x + frame.size.width + 4;
    }
}

- (void)layoutSubviews
{
    squareSide = 100;
    
    
    
    
    CGFloat totalWidth = self.rowAssets.count * squareSide + (self.rowAssets.count - 1) * 4;
    
    
    
    if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        while(totalWidth > [UIScreen mainScreen].bounds.size.height)
        {
            squareSide = squareSide - 1;
            totalWidth = self.rowAssets.count * squareSide + (self.rowAssets.count - 1) * 4;
        }
    }
    else if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        while(totalWidth > [UIScreen mainScreen].bounds.size.width)
        {
            squareSide = squareSide - 1;
            totalWidth = self.rowAssets.count * squareSide + (self.rowAssets.count - 1) * 4;
        }
    }
    else
    {
        while(totalWidth > [UIScreen mainScreen].bounds.size.width)
        {
            squareSide = squareSide - 1;
            totalWidth = self.rowAssets.count * squareSide + (self.rowAssets.count - 1) * 4;
        }
    }
    
   
    
    CGFloat startX = (self.bounds.size.width - totalWidth) / 2;
    
	CGRect frame = CGRectMake(startX, 2, squareSide, squareSide);
	
	for (int i = 0; i < [_rowAssets count]; ++i) {
		UIImageView *imageView = [_imageViewArray objectAtIndex:i];
		[imageView setFrame:frame];
		[self addSubview:imageView];
        
        UIImageView *overlayView = [_overlayViewArray objectAtIndex:i];
        [overlayView setFrame:frame];
        [self addSubview:overlayView];
		
		frame.origin.x = frame.origin.x + frame.size.width + 4;
	}
}


@end
