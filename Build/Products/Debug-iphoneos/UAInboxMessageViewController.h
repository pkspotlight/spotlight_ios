/*
 Copyright 2009-2015 Urban Airship Inc. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL URBAN AIRSHIP INC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>
#import "UACommon.h"

@class UAInboxMessage;

/**
 * This class is a reference implementation of a view controller embedding
 * a UIWebview sourcing content from a rich push message.
 */
@interface UAInboxMessageViewController : UIViewController <UIWebViewDelegate, UARichContentWindow>

/**
 * The UAInboxMessage being displayed.
 */
@property (nonatomic, strong) UAInboxMessage *message;

/**
 * Set this property to YES is the class should show alert dialogs in erroneous
 * situations, NO otherwise.
 */
@property (nonatomic, assign) BOOL shouldShowAlerts;

/**
 * Block that will be invoked when this class receives a closeWindow message from the webView.
 */
@property (nonatomic, copy) void (^closeBlock)(BOOL animated);

/**
 * Load a UAInboxMessage at a particular index in the message list.
 * @param index The corresponding index in the message list as an integer.
 */
- (void)loadMessageAtIndex:(NSUInteger)index;

/**
 * Load a UAInboxMessage by message ID.
 * @param mid The message ID as an NSString.
 */
- (void)loadMessageForID:(NSString *)mid;

@end
