//
//  BBSplashViewController.m
//  BarBuddies
//
//  Created by Shotaro Takada and Willian Hua on 10/18/14.
//  Copyright (c) 2014 TCNJ. All rights reserved.
//
//  This class initializes the splashView, setting the background image and making the entire screen a button to
//  navigate to the next screen on touch.

#import "BBSplashViewController.h"
#import "BBLogInViewController.h"

@interface BBSplashViewController ()

@end

@implementation BBSplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    // Initialize SplashView to fill entire screen
    CGRect frame = [UIScreen mainScreen].bounds;
    //UIView *splashView = [[UIView alloc] initWithFrame:frame];
    //splashView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"IOS_Splashscreenr.jpg"]];
    
    // Set title of first view
    UINavigationItem *navItem = self.navigationItem;
    navItem.title = @"SplashScreen";
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [super viewWillAppear:YES];
    
    // Show Splash View
    //self.view = splashView;
    
    // Create button for whole screen, Used to move to next screen on touch
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
}

-(void) buttonClicked:(UIButton*)sender
{
    // Push LogInView onto the Navigation Stack as the next screen
    BBLogInViewController *logInViewController = [[BBLogInViewController alloc]init];
    [self.navigationController pushViewController:logInViewController animated:YES];
    
}

@end
