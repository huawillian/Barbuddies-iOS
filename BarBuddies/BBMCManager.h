//
//  BBMCManager.h
//  BarBuddies
//
//  Created by Shotaro Takada and Willian Hua on 10/22/14.
//  Copyright (c) 2014 TCNJ. All rights reserved.
//
//  Modified from http://www.appcoda.com/intro-multipeer-connectivity-framework-ios-programming/

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface BBMCManager : UIViewController <MCSessionDelegate>

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCBrowserViewController *browser;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;

@property NSString *ProfileName;
@property NSString *PhoneNumber;
@property NSInteger ProfilePicture;
@property NSString *SessionName;

@property UITabBarController *tabBarController;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName;
-(void)setupMCBrowser;
-(void)advertiseSelf:(BOOL)shouldAdvertise;

@end
