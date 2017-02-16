//
//  UIAlertController+Additions.m
//  
//
//  Created by Peter Kamm on 2/2/17.
//
//

#import "UIAlertController+Additions.h"

@implementation UIAlertController (Additions)

+(void)showOkMessage:(NSString*)message {
    UIAlertController* alreadySent = [UIAlertController alertControllerWithTitle:@""
                                                                         message:message
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    [alreadySent addAction:[UIAlertAction actionWithTitle:@"OK"
                                                    style:UIAlertActionStyleDefault
                                                  handler:nil]];
}

@end
