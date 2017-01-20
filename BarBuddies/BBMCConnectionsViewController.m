//
//  BBMCConnectionsViewController.m
//  BarBuddies
//
//  Created by Shotaro Takada and Willian Hua on 10/22/14.
//  Copyright (c) 2014 TCNJ. All rights reserved.
//
//  This class is used to display and handle the MC session information. We also handle browsing and advertising in this class as well as table handling. The majority of the messages in the MC session will go through this class, so we handle adding, removing, alerts, and notifications here.
//
//  Modified from http://www.appcoda.com/intro-multipeer-connectivity-framework-ios-programming/

#import "BBMCConnectionsViewController.h"
#import <MessageUI/MessageUI.h>

@interface BBMCConnectionsViewController () <MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *ProPic;
@property (weak, nonatomic) IBOutlet UILabel *HelloText;
@property (weak, nonatomic) IBOutlet UILabel *HelloPhone;
@property (weak, nonatomic) IBOutlet UILabel *SessName;
@property (weak, nonatomic) IBOutlet UILabel *VisibleLabel;
@property (weak, nonatomic) IBOutlet UILabel *ConnectLabel;

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification;

@end

@implementation BBMCConnectionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Setup TabBar title and image
        self.tabBarItem.title = @"Connections";
        self.tabBarItem.image = [UIImage imageNamed:@"ConnectionsIcon.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup UI Values: Pictures, Text, Phone Number, Session Name
    for(int i=0; i<10; i++)
    {
        if(self.ProfilePicture == i)
        {
            NSString *picture = [NSString stringWithFormat:@"pic%i.jpg", i];
            [self.ProPic setImage:[UIImage imageNamed:picture]];
        }
    }
    
    [self.HelloText setText:[NSString stringWithFormat:@"%@", self.ProfileName]];
    [self.HelloPhone setText:[NSString stringWithFormat:@"%@", self.PhoneNumber]];
    
    if([self.SessionName length] == 0)
    {
        [self.SessName setText:[NSString stringWithFormat:@"Not Connected to Session"]];
    }
    else
    {
        [self.SessName setText:[NSString stringWithFormat:@"%@", self.SessionName]];
    }

    
    // Get reference to app delegate
    _appDelegate = (BBAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Initialize MCManager object and set advertise to true
    [[_appDelegate mcManager] setupPeerAndSessionWithDisplayName:self.ProfileName];
    [[_appDelegate mcManager] advertiseSelf:_swVisible.isOn];
    
    // Add peerDidChangeStateWithNotification as receiver for state changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
    
    // Initialize Buddies!
    _arrConnectedDevices = [[NSMutableArray alloc] init];
    _arrConnectedNames = [[NSMutableArray alloc] init];
    _arrConnectedPhone = [[NSMutableArray alloc] init];
    _arrConnectedPic = [[NSMutableArray alloc] init];
    
    _arrDisconnectedDevices = [[NSMutableArray alloc] init];
    _arrDisconnectedNames = [[NSMutableArray alloc] init];
    _arrDisconnectedPhone = [[NSMutableArray alloc] init];
    _arrDisconnectedPic = [[NSMutableArray alloc] init];

    
    [_tblConnectedDevices setDelegate:self];
    [_tblConnectedDevices setDataSource:self];
    
    [self.browseForDevices addTarget:self action:@selector(browseForDevices:) forControlEvents:UIControlEventTouchUpInside];
    
    // If Session Name is not set, bring up browser for contacts in a second
    if([self.SessionName isEqualToString:@""])
    {
       [self performSelector:@selector(buttonCallBrowse) withObject:self afterDelay:1];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)buttonCallBrowse
{
    [self.browseForDevices sendActionsForControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - UITextField Delegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    _appDelegate.mcManager.peerID = nil;
    _appDelegate.mcManager.session = nil;
    _appDelegate.mcManager.browser = nil;
    
    if ([_swVisible isOn]) {
        [_appDelegate.mcManager.advertiser stop];
    }
    _appDelegate.mcManager.advertiser = nil;
    
    
    [_appDelegate.mcManager setupMCBrowser];
    [_appDelegate.mcManager advertiseSelf:_swVisible.isOn];
    
    return YES;
}


#pragma mark - Public method implementation

- (IBAction)browseForDevices:(id)sender
{
    [[_appDelegate mcManager] setupMCBrowser];
    [[[_appDelegate mcManager] browser] setDelegate:self];
    [self presentViewController:[[_appDelegate mcManager] browser] animated:YES completion:nil];
}


- (IBAction)toggleVisibility:(id)sender
{
    [_appDelegate.mcManager advertiseSelf:_swVisible.isOn];
    
    if ([_swVisible isOn]) {
        self.VisibleLabel.text = @"Visible to Buddies";
    }
    else
    {
        self.VisibleLabel.text = @"Invisible to Buddies";
    }
}

- (IBAction)toggleConnect:(id)sender {
    if ([_swConnect isOn]){
        self.ConnectLabel.text = @"Showing Connected Buddies";
        [_tblConnectedDevices reloadData];
    }
    else {
        self.ConnectLabel.text = @"Showing Disconnected Buddies";
        [_tblConnectedDevices reloadData];
    }
}


- (IBAction)disconnect:(id)sender
{
    // Add currently connected devices to disconnected list
    for(int i=0; i< [_arrConnectedDevices count]; i++)
    {
        [_arrDisconnectedDevices addObject:[_arrConnectedDevices objectAtIndex:i]];
        [_arrDisconnectedNames addObject:[_arrConnectedNames objectAtIndex:i]];
        [_arrDisconnectedPhone addObject:[_arrConnectedPhone objectAtIndex:i]];
        [_arrDisconnectedPic addObject:[_arrConnectedPic objectAtIndex:i]];
    }
    
    // Remove all connected devices
    [_arrConnectedDevices removeAllObjects];
    [_arrConnectedNames removeAllObjects];
    [_arrConnectedPhone removeAllObjects];
    [_arrConnectedPic removeAllObjects];
    
    // Change UI
    [_tblConnectedDevices reloadData];
    self.SessionName = @"Not Connected to Session";
    self.SessName.text = @"Not Connected to Session";
    
    [_appDelegate.mcManager.session disconnect];
    
    // Pop-up notification
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Disconnect"
                                                      message:@"You have successfully disconnected from the session. Browse for devices to reconnect"
                                                     delegate:self
                                            cancelButtonTitle:@"Return"
                                            otherButtonTitles:nil];
    [message show];
    
    message.delegate = self;
    
}

-(void)addPeer:(NSString *) data
{
    // Called when String received by peers in session is prepended with AddPeer, followed by peer information
    // Separate String into array
    NSArray *info = [data componentsSeparatedByString:@" "];
    
    // Add peer information to peer list information and change session name if exists
    if(([info count] > 4) && [self.SessName.text isEqualToString:@"Not Connected to Session"])
    {
        if([[info objectAtIndex:4] length] != 0)
        {
        self.SessionName = (NSString *)[info objectAtIndex:4];
        [self.SessName setText:[NSString stringWithFormat:@"%@", (NSString *)[info objectAtIndex:4]]];
        }
    }
    
    [self.arrConnectedNames addObject:(NSString *)[info objectAtIndex:2]];
    [self.arrConnectedPhone addObject:(NSString *)[info objectAtIndex:3]];
    
    NSString *picIndexStr = (NSString *)[info objectAtIndex:1];
    [self.arrConnectedPic addObject:[NSNumber numberWithInt:[picIndexStr intValue]]];
}


#pragma mark - MCBrowserViewControllerDelegate method implementation

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}


-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Private method implementation

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification
{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    if (state != MCSessionStateConnecting)
    {
        if (state == MCSessionStateConnected)
        {
            // IF SOMEONE HAS CONNECTED TO SESSION
            [_arrConnectedDevices addObject:peerDisplayName];
            
            // Connected, send Profile Pic Index, Name, and Phone Number
            NSData *dataToSend = [[NSString stringWithFormat:@"AddPeer %ld %@ %@ %@ ", (long)self.ProfilePicture, self.ProfileName, self.PhoneNumber, self.SessionName] dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
            NSError *error;
            
            // Send as reliable type
            [_appDelegate.mcManager.session sendData:dataToSend
                                             toPeers:allPeers
                                            withMode:MCSessionSendDataReliable
                                               error:&error];
            
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }
            

        }
        else if (state == MCSessionStateNotConnected)
        {
            // IF SOMEONE HAS DISCONNECTED FROM SESSION
            if ([_arrConnectedDevices count] > 0)
            {
                
                int indexOfPeer = (int)[_arrConnectedDevices indexOfObject:peerDisplayName];
                
                // Add peer data to disconnected list
                [_arrDisconnectedDevices addObject:[_arrConnectedDevices objectAtIndex:indexOfPeer]];
                [_arrDisconnectedNames addObject:[_arrConnectedNames objectAtIndex:indexOfPeer]];
                [_arrDisconnectedPhone addObject:[_arrConnectedPhone objectAtIndex:indexOfPeer]];
                [_arrDisconnectedPic addObject:[_arrConnectedPic objectAtIndex:indexOfPeer]];
                
                // Send notification that someone has disconnected
                UILocalNotification *backupAlarm = [[UILocalNotification alloc] init];
                
                backupAlarm.fireDate = [NSDate date];
                backupAlarm.timeZone = [NSTimeZone systemTimeZone];
                
                backupAlarm.alertBody = [NSString stringWithFormat:@"%@ has disconnected from your session! View recently disconnected buddies for more information...",[_arrConnectedNames objectAtIndex:indexOfPeer] ];
                backupAlarm.alertAction = @"Show me";
                backupAlarm.soundName = UILocalNotificationDefaultSoundName;
                
                [[UIApplication sharedApplication] scheduleLocalNotification:backupAlarm];
                
                /*
                // Send alert
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Someone Disconnected!"
                                                                  message:[NSString stringWithFormat:@"%@ has disconnected from your session! View recently disconnected buddies for more information...",[_arrConnectedNames objectAtIndex:indexOfPeer] ]
                                                                 delegate:self
                                                        cancelButtonTitle:@"Return"
                                                        otherButtonTitles: nil];
                message.delegate = self;
                [message show];
                */
                
                // Remove peer from connected peers list
                [_arrConnectedDevices removeObjectAtIndex:indexOfPeer];
                [_arrConnectedNames removeObjectAtIndex:indexOfPeer];
                [_arrConnectedPhone removeObjectAtIndex:indexOfPeer];
                [_arrConnectedPic removeObjectAtIndex:indexOfPeer];
                
            }
        }
        [_tblConnectedDevices reloadData];
        
        BOOL peersExist = ([[_appDelegate.mcManager.session connectedPeers] count] == 0);
        [_btnDisconnect setEnabled:!peersExist];
    }
}

#pragma mark - UITableView Delegate and Datasource method implementation
// Same table will be used for connected and disconnected devices
// Will switch between the two data using a switch on the UI

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_swConnect isOn])
        return [_arrConnectedDevices count];
    else
        return [_arrDisconnectedDevices count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    // Initialize the cell with a font
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:@"Cell1"];
        cell.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIFont *myFont = [ UIFont fontWithName: @"Arial" size: 24.0 ];
        cell.textLabel.font = myFont;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    @try
    {
        // Display connected or disconnected peers depending on switch value
        if ([_swConnect isOn])
        {
            for(int i=0; i<10; i++)
            {
                if( [[self.arrConnectedPic objectAtIndex:indexPath.row] intValue] == i)
                {
                    NSString *picture = [NSString stringWithFormat:@"pic%i.jpg", i];
                    cell.imageView.image = [UIImage imageNamed:picture];
                }
            }
        
            cell.textLabel.text = [self.arrConnectedNames objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [self.arrConnectedPhone objectAtIndex:indexPath.row];
        }
        else
        {
            for(int i=0; i<10; i++)
            {
                if( [[self.arrDisconnectedPic objectAtIndex:indexPath.row] intValue] == i)
                {
                    NSString *picture = [NSString stringWithFormat:@"pic%i.jpg", i];
                    cell.imageView.image = [UIImage imageNamed:picture];
                }
            }
            
            cell.textLabel.text = [self.arrDisconnectedNames objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [self.arrDisconnectedPhone objectAtIndex:indexPath.row];
        }
    }
    @catch (NSException * e)
    {
        NSLog(@"Exception: %@", e);
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    
    // Show alert when a cell is selected with content depending on the cell
    if ([_swConnect isOn])
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Profile Name: %@", [self.arrConnectedNames objectAtIndex:indexPath.row]]
                                                          message:[NSString stringWithFormat:@"Phone Number: %@", [self.arrConnectedPhone objectAtIndex:indexPath.row]]
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Message", @"Call", nil];
        [message show];
        
        message.delegate = self;
        
        [message addButtonWithTitle:@"Message"];
        
        [message addButtonWithTitle:@"Call"];
        
        [message show];
    }
    else
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Profile Name: %@", [self.arrDisconnectedNames objectAtIndex:indexPath.row]]
                                                          message:[NSString stringWithFormat:@"Phone Number: %@", [self.arrDisconnectedPhone objectAtIndex:indexPath.row]]
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Message", @"Call", nil];
        [message show];
        
        message.delegate = self;
        
        [message addButtonWithTitle:@"Message"];
        
        [message addButtonWithTitle:@"Call"];
        
        [message show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Alert format and action handler
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Cancel"])
    {
        NSLog(@"Cancel");
    }
    else if([title isEqualToString:@"Message"])
    {
        // Attempt to open message view
        if([MFMessageComposeViewController canSendText])
        {
            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
            
            controller.body = [NSString stringWithFormat:@" - BarBuddies App"];
            controller.messageComposeDelegate = self;
        }
        else
        {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                              message:@"BarBuddies is unable to send SMS messages with your device"
                                                             delegate:self
                                                    cancelButtonTitle:@"Return"
                                                    otherButtonTitles: nil];
            message.delegate = self;
            
            [message show];
        }
    }
    else if([title isEqualToString:@"Call"])
    {
        // Attempt to call
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                          message:@"BarBuddies is unable to call with your device"
                                                         delegate:self
                                                cancelButtonTitle:@"Return"
                                                otherButtonTitles: nil];
        message.delegate = self;
        
        [message show];
        
        NSString *stringURL = @"tel://8004664411";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    
}

@end
