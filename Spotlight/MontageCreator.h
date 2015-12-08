//
//  MontageUtilities.h
//  Spotlight
//
//  Created by Peter Kamm on 12/7/15.
//  Copyright © 2015 Spotlight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MontageCreator : NSObject

+ (MontageCreator *)sharedCreator;

- (void)createMontageWithMedia:(NSArray*)mediaArray completion:(void (^ __nullable)(void))completion;

@end
