//
//  BBAppDelegate.h
//  BarBuddies
//
//  Created by Shotaro Takada and Willian Hua on 10/9/14.
//  Copyright (c) 2014 TCNJ. All rights reserved.
//
#import "BBMCManager.h"
#import <UIKit/UIKit.h>

@interface BBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BBMCManager *mcManager;

@end
