//
//  BBMCManager.m
//  BarBuddies
//
//  Created by Shotaro Takada and Willian Hua on 10/22/14.
//  Copyright (c) 2014 TCNJ. All rights reserved.
//
//  This class manages all of the aspects of the Multipeer Connectivity Framework.
//  It also sets up the tab bar controllers to navigate through the Chat view and Connections view.
//
//  Modified from http://www.appcoda.com/intro-multipeer-connectivity-framework-ios-programming/

#import "BBMCManager.h"
#import "BBMCConnectionsViewController.h"
#import "BBMCChatViewController.h"
#import "BBAppDelegate.h"

@implementation BBMCManager

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    // Set up Connections View Controller
    BBMCConnectionsViewController *cvc = [[BBMCConnectionsViewController alloc]init];
    cvc.ProfileName = self.ProfileName;
    cvc.ProfilePicture = self.ProfilePicture;
    cvc.PhoneNumber = self.PhoneNumber;
    cvc.SessionName = self.SessionName;
    
    // Set up Chat View Controller
    BBMCChatViewController *chvc = [[BBMCChatViewController alloc]init];
    chvc.connectionsViewController = cvc;
    
    // Set up TabBar Controller to control navigation between the views
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[chvc, cvc];
    [self.tabBarController setSelectedIndex:1];
    
    // KEEPING APP TASKS RUNNING ON THE FOREGROUND WHEN BACKGROUNDED
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"Background handler called. Not running background tasks anymore.");
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }];
    
    BBAppDelegate *appDelegate = (BBAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = self.tabBarController;

}

-(id)init
{
    self = [super init];
    
    if (self) {
        _peerID = nil;
        _session = nil;
        _browser = nil;
        _advertiser = nil;
    }
    
    return self;
}


#pragma mark - Public method implementation

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName
{
    _peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
    
    _session = [[MCSession alloc] initWithPeer:_peerID];
    _session.delegate = self;
}


-(void)setupMCBrowser
{
    _browser = [[MCBrowserViewController alloc] initWithServiceType:@"chat-files" session:_session];
}


-(void)advertiseSelf:(BOOL)shouldAdvertise
{
    if (shouldAdvertise) {
        _advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:@"chat-files"
                                                           discoveryInfo:nil
                                                                 session:_session];
        [_advertiser start];
    }
    else{
        [_advertiser stop];
        _advertiser = nil;
    }
}


#pragma mark - MCSession Delegate method implementation


-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSDictionary *dict = @{@"peerID": peerID,
                           @"state" : [NSNumber numberWithInt:state]
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification"
                                                        object:nil
                                                      userInfo:dict];
}


-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSDictionary *dict = @{@"data": data,
                           @"peerID": peerID
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
                                                        object:nil
                                                      userInfo:dict];
}


-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
    NSDictionary *dict = @{@"resourceName"  :   resourceName,
                           @"peerID"        :   peerID,
                           @"progress"      :   progress
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidStartReceivingResourceNotification"
                                                        object:nil
                                                      userInfo:dict];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [progress addObserver:self
                   forKeyPath:@"fractionCompleted"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    });
}


-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
    NSDictionary *dict = @{@"resourceName"  :   resourceName,
                           @"peerID"        :   peerID,
                           @"localURL"      :   localURL
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishReceivingResourceNotification"
                                                        object:nil
                                                      userInfo:dict];
    
}


-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCReceivingProgressNotification"
                                                        object:nil
                                                      userInfo:@{@"progress": (NSProgress *)object}];
}


@end
