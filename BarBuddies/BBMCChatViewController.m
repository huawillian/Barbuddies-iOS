//
//  BBMCChatViewController.m
//  BarBuddies
//
//  Created by Shotaro Takada and Willian Hua on 10/22/14.
//  Copyright (c) 2014 TCNJ. All rights reserved.
//
//  This class is used to display and handle the MC session information regarding chatting between peers inside a MC session. The String messages sent by any peer will be received here and handled accordingly. If AddPeer is the first word, then we will send the string to Connections View Controller class to handle the command. Otherwise, just display the message.
//
//  Modified from http://www.appcoda.com/intro-multipeer-connectivity-framework-ios-programming/

#import "BBMCChatViewController.h"
#import "BBAppDelegate.h"

@interface BBMCChatViewController ()

@property (nonatomic, strong) BBAppDelegate *appDelegate;

-(void)sendMyMessage;
-(void)didReceiveDataWithNotification:(NSNotification *)notification;

@end


@implementation BBMCChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup TabBar title and image
    self.tabBarItem.title = @"Chat";
    self.tabBarItem.image = [UIImage imageNamed:@"ChatIcon.png"];
    
    
    self.appDelegate = (BBAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    
    self.txtMessage.delegate = self;
    self.tvChat.editable = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextField Delegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendMyMessage];
    return YES;
}


#pragma mark - IBAction method implementation

- (IBAction)sendMessage:(id)sender
{
    [self sendMyMessage];
}

- (IBAction)cancelMessage:(id)sender
{
    [_txtMessage resignFirstResponder];
}


#pragma mark - Private method implementation

-(void)sendMyMessage
{
    // Send Message to to all peers
    
    NSData *dataToSend = [_txtMessage.text dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
    NSError *error;
    
    // Use MCManager's method to send data as reliable
    [self.appDelegate.mcManager.session sendData:dataToSend
                                     toPeers:allPeers
                                    withMode:MCSessionSendDataReliable
                                       error:&error];
    
    // If not error, then show message on TVChat
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    else
    {
        [self.tvChat setText:[self.tvChat.text stringByAppendingString:[NSString stringWithFormat:@"I wrote:\n%@\n\n", self.txtMessage.text]]];
        [self.txtMessage setText:@""];
        [self.txtMessage resignFirstResponder];
    
        self.tvChat.editable = YES;
        self.tvChat.font = [UIFont fontWithName:@"Helvetica Neue" size:25.0f];
        self.tvChat.editable = NO;
    }
}


-(void)didReceiveDataWithNotification:(NSNotification *)notification
{
    // All messages sent through MCManager from another device will be received here
    
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    NSString *textType;
    
    // Check if the message is a command to add a peer
    if([receivedText length] > 8) textType = [receivedText substringToIndex:7];
    else textType = @"";
    
    if (![textType isEqualToString:@"AddPeer"])
    {
        // Display message if not command
        [_tvChat performSelectorOnMainThread:@selector(setText:) withObject:[_tvChat.text stringByAppendingString:[NSString stringWithFormat:@"%@ wrote:\n%@\n\n", peerDisplayName, receivedText]] waitUntilDone:NO];
        
        self.tvChat.editable = YES;
        self.tvChat.font = [UIFont fontWithName:@"Helvetica Neue" size:25.0f];
        self.tvChat.editable = NO;
    }
    else
    {
        // If command, then call ConnectionsView addPeer method to handle
        NSString *data = [receivedText substringFromIndex:7];
        [self.connectionsViewController addPeer:data];
    }
}

@end

