//
//  AppDelegate.m
//  OpenVK Me
//
//  Created by miles on 15/08/22.
//  Copyright (c) 2022 Miles Prower. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UINavigationBar.appearance setBackgroundImage:[UIImage imageNamed:@"header"] forBarMetrics:UIBarMetricsDefault];
    
    [UIBarButtonItem.appearance setBackgroundImage:[UIImage imageNamed:@"blue_btn_nav"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [UIBarButtonItem.appearance setBackgroundImage:[UIImage imageNamed:@"blue_btn_nav_hl"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    [UIBarButtonItem.appearance setBackButtonBackgroundImage:[[UIImage imageNamed:@"blue_back_btn_nav"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [UIBarButtonItem.appearance setBackButtonBackgroundImage:[[UIImage imageNamed:@"blue_back_btn_nav_hl"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];

    
    NSUserDefaults *userDefault = [[NSUserDefaults alloc]init];
    [userDefault registerDefaults:@{@"token": @"",
     @"instances": @[
        @{
            @"serverURL": @"openvk.su",
            @"isHTTPS": @1,
        },
        @{
            @"serverURL": @"openvk.uk",
            @"isHTTPS": @1,
        },
        @{
            @"serverURL": @"openvk.co",
            @"isHTTPS": @0,
        },
        @{
            @"serverURL": @"social.fetbuk.ru",
            @"isHTTPS": @1,
        },
        @{
            @"serverURL": @"vepurovk.xyz",
            @"isHTTPS": @1,
        },
    ],
    @"selectedInstance": @0,
    @"userID": @0,
    @"firstStartup": @YES,
    }];
    [userDefault synchronize];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    if (![[NSUserDefaults.standardUserDefaults stringForKey:@"token"] isEqual: @""]) {
        [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"firstStartup"];
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"MainApp"];
        [self.window setRootViewController:viewController];
    } else {
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginScreen"];
        [self.window setRootViewController:viewController];
    }
	
    // Override point for customization after application launch.
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
