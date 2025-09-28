//
//  MainTabController.m
//  OpenVK
//
//  Created by miles on 04/11/22.
//  Copyright (c) 2022 Miles Prower. All rights reserved.
//

#import "MainTabController.h"
#import "APICommunicator.h"

@interface MainTabController ()

@end

@implementation MainTabController

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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                  target:self
                                                selector:@selector(updateBadges:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateBadges:(NSTimer*)timer
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *count = [APICommunicator getBadges];
        
        NSString *messages = [NSString stringWithFormat:@"%@",[count objectForKey:@"messages"]];
        NSString *friends = [NSString stringWithFormat:@"%@",[count objectForKey:@"friends"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![messages isEqual:@"0"]) {
                [[self.tabBar.items objectAtIndex:2] setBadgeValue:messages];
            }
            
            if (![friends isEqual:@"0"]) {
                [[self.tabBar.items objectAtIndex:3] setBadgeValue:friends];
            }
        });
    });
}

@end
