//
//  MontageUtilities.h
//  Spotlight
//
//  Created by Peter Kamm on 12/7/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MontageCreator : NSObject

+ (MontageCreator *)sharedCreator;

- (void)createMontageWithMedia:(NSArray*)mediaArray
                     songTitle:(NSString*)songTitle
                    completion:(void (^)(AVPlayerItem* item))completion;

@end
