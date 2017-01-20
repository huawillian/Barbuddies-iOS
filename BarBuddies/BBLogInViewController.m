//
//  BBLogInViewController.m
//  BarBuddies
//
//  Created by Shotaro Takada and Willian Hua on 10/18/14.
//  Copyright (c) 2014 TCNJ. All rights reserved.
//
//  This class allows the user to input thier information into the system: Name, Phone Number, and Profile Name. The information is not saved on disk and not given out. The data will be used to identify the user during the session.

#import "BBLogInViewController.h"
#import "BBSessionChooserViewController.h"
#import "BBMCManager.h"


@interface BBLogInViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *ProfileName;
@property (weak, nonatomic) IBOutlet UITextField *PhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *pic1;
@property (weak, nonatomic) IBOutlet UIButton *pic2;
@property (weak, nonatomic) IBOutlet UIButton *pic3;
@property (weak, nonatomic) IBOutlet UIButton *pic4;
@property (weak, nonatomic) IBOutlet UIButton *pic5;
@property (weak, nonatomic) IBOutlet UIButton *pic6;
@property (weak, nonatomic) IBOutlet UIButton *pic7;
@property (weak, nonatomic) IBOutlet UIButton *pic8;
@property (weak, nonatomic) IBOutlet UIButton *pic9;
@property  NSInteger picIndex;
@property (weak, nonatomic) IBOutlet UIButton *InfoButton;

@end


@implementation BBLogInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up navigation controller for LogInView
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [super viewWillAppear:YES];
    self.navigationItem.title = @"Log In";
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Next"  style:UIBarButtonItemStyleBordered  target:self action:@selector(loadNextViewController:)];
    self.navigationItem.rightBarButtonItem = bbi;
    
    // Set up Profile Name textfield
    self.ProfileName.text = @"";
    self.ProfileName.placeholder = @"e.g. Billy_Hua";
    self.ProfileName.returnKeyType = UIReturnKeyDone;
    self.ProfileName.enablesReturnKeyAutomatically = YES;
    self.ProfileName.delegate = self;
    
    // Set up Phone Number textfield
    self.PhoneNumber.text = @"";
    self.PhoneNumber.placeholder = @"e.g. 123-456-7894";
    self.PhoneNumber.returnKeyType = UIReturnKeyDone;
    self.PhoneNumber.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.PhoneNumber.enablesReturnKeyAutomatically = YES;
    self.PhoneNumber.delegate = self;
    
    // Set up Profile Picture Selection
    self.picIndex = 0;
    [self.pic1 addTarget:self action:@selector(select1:) forControlEvents:UIControlEventTouchUpInside];
    [self.pic2 addTarget:self action:@selector(select2:) forControlEvents:UIControlEventTouchUpInside];
    [self.pic3 addTarget:self action:@selector(select3:) forControlEvents:UIControlEventTouchUpInside];
    [self.pic4 addTarget:self action:@selector(select4:) forControlEvents:UIControlEventTouchUpInside];
    [self.pic5 addTarget:self action:@selector(select5:) forControlEvents:UIControlEventTouchUpInside];
    [self.pic6 addTarget:self action:@selector(select6:) forControlEvents:UIControlEventTouchUpInside];
    [self.pic7 addTarget:self action:@selector(select7:) forControlEvents:UIControlEventTouchUpInside];
    [self.pic8 addTarget:self action:@selector(select8:) forControlEvents:UIControlEventTouchUpInside];
    [self.pic9 addTarget:self action:@selector(select9:) forControlEvents:UIControlEventTouchUpInside];
 
    // Set up Info Button
    [self.InfoButton addTarget:self action:@selector(info:) forControlEvents:UIControlEventTouchUpInside];

    // Send alert
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Welcome to BarBuddies!"
                                                      message:@"This app allows you to keep track of whether or not your buddies are in your vicinity through Bluetooth. Unlike other apps that keep track of other people, BarBuddies won't pinpoint the exact location of your buddies, so there won't be any privacy concerns."
                                                     delegate:self
                                            cancelButtonTitle:@"Got it!"
                                            otherButtonTitles: nil];
    message.delegate = self;
    [message show];
}

-(void) info:(UIButton*)sender
{
    // Send alert
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Getting Started"
                                                      message:@"To get started, enter your name, phone number and choose an avatar you like. Then, either choose to join a session or create one. One person your group of buddies will create the session, and all the others will join. The person creating the session will have the option of inviting people in their contact list to the session through SMS (given your device is capable of SMS). Afterwards, users who created the session and users who join sessions will be brought to the same screen, where they can browse for devices to connect to, connect with them, and chat with them. "
                                                     delegate:self
                                            cancelButtonTitle:@"Return"
                                            otherButtonTitles: nil];
    message.delegate = self;
    [message show];
}

-(void) select1:(UIButton*)sender
{
    self.picIndex = 1;
}

-(void) select2:(UIButton*)sender
{
    self.picIndex = 2;
}

-(void) select3:(UIButton*)sender
{
    self.picIndex = 3;
}

-(void) select4:(UIButton*)sender
{
    self.picIndex = 4;
}

-(void) select5:(UIButton*)sender
{
    self.picIndex = 5;
}

-(void) select6:(UIButton*)sender
{
    self.picIndex = 6;
}

-(void) select7:(UIButton*)sender
{
    self.picIndex = 7;
}

-(void) select8:(UIButton*)sender
{
    self.picIndex = 8;
}

-(void) select9:(UIButton*)sender
{
    self.picIndex = 9;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)loadNextViewController:(UIButton*)sender
{
    // Push SessionChooserView onto the Navigation Stack as the next screen
    BBSessionChooserViewController *sessionChooserViewController = [[BBSessionChooserViewController alloc]init];
    
    // Check if text fields have been set
    // If not, set default value for each...
    // Get First word of Phone Number and Profile Name
    // Pass data to next View
    if([self.PhoneNumber.text isEqualToString:@""])
    {
        sessionChooserViewController.PhoneNumber = @"nil";
    }
    else
    {
        NSArray *data = [self.PhoneNumber.text componentsSeparatedByString:@" "];
        sessionChooserViewController.PhoneNumber = [data objectAtIndex:0];
    }
    
    if([self.ProfileName.text isEqualToString:@""])
    {
        sessionChooserViewController.ProfileName = @"nil";
    }
    else
    {
        NSArray *data = [self.ProfileName.text componentsSeparatedByString:@" "];
        sessionChooserViewController.ProfileName = [data objectAtIndex:0];
    }
    
    if((int)self.picIndex == 0)
    {
        sessionChooserViewController.ProfilePicture = 1;
    }
    else
    {
        sessionChooserViewController.ProfilePicture = self.picIndex;
    }
    
    [self.navigationController pushViewController:sessionChooserViewController animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
