//
//  UIViewController+AlertAdditions.m
//  Spotlight
//
//  Created by Peter Kamm on 2/16/17.
//  Copyright © 2017 Spotlight. All rights reserved.
//

#import "UIViewController+AlertAdditions.h"

@implementation UIViewController (AlertAdditions)

-(void)showOkMessage:(NSString*)message {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UIAlertController* alreadySent = [UIAlertController alertControllerWithTitle:@""
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
        [alreadySent addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
        [self presentViewController:alreadySent
                           animated:YES
                         completion:nil];
    }];
}

@end
