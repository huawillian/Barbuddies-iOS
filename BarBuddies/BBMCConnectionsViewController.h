//
//  BBMCConnectionsViewController.h
//  BarBuddies
//
//  Created by Shotaro Takada and Willian Hua on 10/22/14.
//  Copyright (c) 2014 TCNJ. All rights reserved.
//
//  Modified from http://www.appcoda.com/intro-multipeer-connectivity-framework-ios-programming/

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "BBAppDelegate.h"

@interface BBMCConnectionsViewController : UIViewController <MCBrowserViewControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property NSString *ProfileName;
@property NSString *PhoneNumber;
@property NSInteger ProfilePicture;
@property NSString *SessionName;
@property (nonatomic, strong) BBAppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *arrConnectedDevices;
@property (nonatomic, strong) NSMutableArray *arrConnectedNames;
@property (nonatomic, strong) NSMutableArray *arrConnectedPhone;
@property (nonatomic, strong) NSMutableArray *arrConnectedPic;

@property (nonatomic, strong) NSMutableArray *arrDisconnectedDevices;
@property (nonatomic, strong) NSMutableArray *arrDisconnectedNames;
@property (nonatomic, strong) NSMutableArray *arrDisconnectedPhone;
@property (nonatomic, strong) NSMutableArray *arrDisconnectedPic;

@property (weak, nonatomic) IBOutlet UISwitch *swVisible;
@property (weak, nonatomic) IBOutlet UISwitch *swConnect;

@property (weak, nonatomic) IBOutlet UITableView *tblConnectedDevices;
@property (weak, nonatomic) IBOutlet UIButton *btnDisconnect;
@property (weak, nonatomic) IBOutlet UIButton *browseForDevices;

- (IBAction)browseForDevices:(id)sender;
- (IBAction)toggleVisibility:(id)sender;
- (IBAction)toggleConnect:(id)sender;
- (IBAction)disconnect:(id)sender;

- (void)addPeer:(NSString *) data;


@end
