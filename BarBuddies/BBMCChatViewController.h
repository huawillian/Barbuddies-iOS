//
//  BBMCChatViewController.h
//  BarBuddies
//
//  Created by Shotaro Takada and Willian Hua on 10/22/14.
//  Copyright (c) 2014 TCNJ. All rights reserved.
//
//  Modified from http://www.appcoda.com/intro-multipeer-connectivity-framework-ios-programming/

#import <UIKit/UIKit.h>
#import "BBMCConnectionsViewController.h"

@interface BBMCChatViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtMessage;
@property (weak, nonatomic) IBOutlet UITextView *tvChat;
@property (weak) BBMCConnectionsViewController *connectionsViewController;

- (IBAction)sendMessage:(id)sender;
- (IBAction)cancelMessage:(id)sender;

@end
