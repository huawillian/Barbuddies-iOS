//
//  BBAppDelegate.m
//  BarBuddies
//
//  Created by Shotaro Takada and Willian Hua on 10/9/14.
//  Copyright (c) 2014 TCNJ. All rights reserved.
//
//  This class is the main app delegate, creating and setting the splash screen as the root of the
//  navigation controller. Additionally initializes the MC Framework.


#import "BBAppDelegate.h"
#import "BBSplashViewController.h"

@implementation BBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Create the Splash Screen
    BBSplashViewController *splashViewController = [[BBSplashViewController alloc] init];
    
    // Set the Splash Screen as the root of the Navigation Controller
    // Set Navigation Controller as the root of the app window
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:splashViewController];
    self.window.rootViewController = navController;
    
    // Show the window
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // Initialize Multipeer Connectivity Framework, to be referenced in BBMCManager
    _mcManager = [[BBMCManager alloc] init];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
