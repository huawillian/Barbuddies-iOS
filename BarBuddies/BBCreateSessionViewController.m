//
//  BBCreateSessionViewController.m
//  BarBuddies
//
//  Created by Shotaro Takada and Willian Hua on 10/18/14.
//  Copyright (c) 2014 TCNJ. All rights reserved.
//
//  This class is used to handle session creation. User will be able to set the session name and invite buddies from their contacts. The invite will be in a form of a text message. Afterwards, the user will be directed to the MCManager views.

#import "BBCreateSessionViewController.h"
#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>
#import "BBExistingSessionViewController.h"
#import "BBMCManager.h"


@interface BBCreateSessionViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *ContactsTable;
@property (weak, nonatomic) IBOutlet UITextField *SessionName;

@property (nonatomic, strong) NSArray *arrayOfPeople;
@property (nonatomic, assign) CFArrayRef people;
@property (nonatomic, strong) NSMutableSet *selectedPeople;
@end

@implementation BBCreateSessionViewController

@synthesize arrayOfPeople = _arrayOfPeople;
@synthesize people = _people;
@synthesize selectedPeople = _selectedPeople;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (NSMutableSet *) selectedPeople
{
    if (_selectedPeople == nil)
    {
        _selectedPeople = [[NSMutableSet alloc] init];
    }
    
    return _selectedPeople;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up navigation controller for CreateSessionView
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Next"  style:UIBarButtonItemStyleBordered  target:self action:@selector(loadNextViewController:)];
    self.navigationItem.rightBarButtonItem = bbi;
    
    // Set up Session Name textfield
    self.SessionName.placeholder = @"e.g. Something Cool!";
    self.SessionName.returnKeyType = UIReturnKeyDone;
    self.SessionName.enablesReturnKeyAutomatically = YES;
    self.SessionName.delegate = self;
    
    // Set up Contacts Table
    self.ContactsTable.delegate = self;
    self.ContactsTable.dataSource = self;
    [self.view addSubview:self.ContactsTable];
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    self.people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    self.arrayOfPeople = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
    [self.ContactsTable reloadData];
}

- (void)loadNextViewController:(UIButton*)sender
{
    if([MFMessageComposeViewController canSendText])
	{
        // If can send text, then show Message View and add selected contacts as recipients to be sent.
        // Create template as message body.
        
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        NSMutableArray *people = [[NSMutableArray alloc] init];
        
        for(NSObject *pperson in  self.selectedPeople)
        {
            ABMultiValueRef phoneNumbers = ABRecordCopyValue((__bridge ABRecordRef)(pperson), kABPersonPhoneProperty);
            NSString *phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, 0));
            [people addObject:phoneNumber];
            CFRelease(phoneNumbers);
        }
        
		controller.body = [NSString stringWithFormat:@"Hello Guys! This is %@ using the BarBuddies App. Come join the session I just created. It's called %@!", self.ProfileName, self.SessionName.text];
		controller.recipients = people;
		controller.messageComposeDelegate = self;
	}
    else
    {
        // If cannot send text, Initialize MCManger
        // and push to navigation controller stack
        [[[UIAlertView alloc] initWithTitle:nil message:@"Your device is unable to send SMS messages. " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        BBMCManager *joinViewController = [[BBMCManager alloc]init];
        joinViewController.ProfileName = self.ProfileName;
        joinViewController.ProfilePicture = self.ProfilePicture;
        joinViewController.PhoneNumber = self.PhoneNumber;
        
        // Set default value for Session Name if not set
        // Only keep first word
        if([self.SessionName.text length] != 0)
        {
            joinViewController.SessionName = self.SessionName.text;
        }
        else
        {
            NSArray *data = [self.SessionName.text componentsSeparatedByString:@" "];
            joinViewController.SessionName = [data objectAtIndex:0];
        }
        
        [self.navigationController pushViewController:joinViewController animated:YES];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactCell";
    
    // Initilize cell as clear color
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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

    int index = (int)indexPath.row;
    
    // Retrieve names and phone numbers
    ABRecordRef person = CFArrayGetValueAtIndex(self.people, index);
    NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString* lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    ABMultiValueRef phoneNumbers = ABRecordCopyValue((person), kABPersonPhoneProperty);
    NSString *phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, 0));
    
    // Get first phone number and name
    NSString *name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    NSString *phone = [NSString stringWithFormat:@"%@", phoneNumber];
    
    // Set cell values
    cell.textLabel.text = name;
    cell.detailTextLabel.text = phone;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayOfPeople.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Selecting and Displaying Multiple contacts
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    id person = [self.arrayOfPeople objectAtIndex:indexPath.row];
    
    // Toggle cell's background color for selecitng and deselecting
    // Add contacts depending on toggle
    if (cell.backgroundColor == [UIColor clearColor])
    {
        cell.backgroundColor = [UIColor colorWithRed:175.0f/255.0f green:238.0f/255.0f blue:248.0f/255.0f alpha:1.0f];
        [self.selectedPeople addObject:person];
    } else
    {
        cell.backgroundColor = [UIColor clearColor];
        [self.selectedPeople removeObject:person];
    }

}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
