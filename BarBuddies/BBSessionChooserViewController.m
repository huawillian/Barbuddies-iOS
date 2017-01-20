//
//  BBSessionChooserViewController.m
//  BarBuddies
//
//  Created by Shotaro Takada and Willian Hua on 10/18/14.
//  Copyright (c) 2014 TCNJ. All rights reserved.
//
//  This class handles the user decision to create or join session. It will create object depending on the user's choice. Also, this class will handle contacts accessibility permissions. If contact permissions are given to the app, we will create the CreateSessionViewController class.

#import "BBSessionChooserViewController.h"
#import "BBExistingSessionViewController.h"
#import "BBCreateSessionViewController.h"
#import "BBMCManager.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface BBSessionChooserViewController ()

@property (weak, nonatomic) IBOutlet UIButton *JoinSessionButton;
@property (weak, nonatomic) IBOutlet UIButton *CreateSessionButton;
@property (weak, nonatomic) IBOutlet UILabel *HelloText;
@property (weak, nonatomic) IBOutlet UIImageView *Pic;

@end


@implementation BBSessionChooserViewController

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
    [self.navigationItem setHidesBackButton:NO animated:YES];
    [super viewWillAppear:YES];
    self.navigationItem.title = @"Session";
    
    // Set up button controls for Join or Create Session Buttons
    [self.JoinSessionButton addTarget:self action:@selector(buttonClicked1:) forControlEvents:UIControlEventTouchUpInside];
    [self.CreateSessionButton addTarget:self action:@selector(buttonClicked2:) forControlEvents:UIControlEventTouchUpInside];
    
    // Display Profile Picture
    for(int i=0; i<10; i++)
    {
        if(self.ProfilePicture == i)
        {
            NSString *picture = [NSString stringWithFormat:@"pic%i.jpg", i];
            [self.Pic setImage:[UIImage imageNamed:picture]];
        }
    }
    
    // Display Name
    [self.HelloText setText:[NSString stringWithFormat:@"Hello, %@!", self.ProfileName]];
}


-(void) buttonClicked1:(UIButton*)sender
{
    // Push MCManager onto the Navigation Stack as the next screen and pass data through
    BBMCManager *joinViewController = [[BBMCManager alloc]init];
    joinViewController.ProfileName = self.ProfileName;
    joinViewController.ProfilePicture = self.ProfilePicture;
    joinViewController.PhoneNumber = self.PhoneNumber;
    joinViewController.SessionName = @"";
    [self.navigationController pushViewController:joinViewController animated:YES];
}

-(void) buttonClicked2:(UIButton*)sender
{
    // Ask user for Contacts Access Permissions
    // Push either MCManager or CreateSessionView onto navigation controller stack depending on the permissions

    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);

    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted)
    {
        BBCreateSessionViewController *createViewController = [[BBCreateSessionViewController alloc]init];
        createViewController.ProfileName = self.ProfileName;
        createViewController.ProfilePicture = self.ProfilePicture;
        createViewController.PhoneNumber = self.PhoneNumber;
        [self.navigationController pushViewController:createViewController animated:YES];
    }
    else
    {
        BBMCManager *joinViewController = [[BBMCManager alloc]init];
        joinViewController.ProfileName = self.ProfileName;
        joinViewController.ProfilePicture = self.ProfilePicture;
        joinViewController.PhoneNumber = self.PhoneNumber;
        joinViewController.SessionName = @"";
        [self.navigationController pushViewController:joinViewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
