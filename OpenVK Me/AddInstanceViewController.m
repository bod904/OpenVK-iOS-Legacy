//
//  AddInstanceViewController.m
//  OpenVK Me
//
//  Created by miles on 16/08/22.
//  Copyright (c) 2022 Miles Prower. All rights reserved.
//

#import "AddInstanceViewController.h"

@interface AddInstanceViewController ()
@property (weak, nonatomic) IBOutlet UITextField *URLField;
@property (weak, nonatomic) IBOutlet UISwitch *HTTPSSwitch;

@end

@implementation AddInstanceViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)AddAction:(id)sender {
    NSString* urlText = [self URLField].text;
    
    if ([urlText isEqual: @"api.vk.com"] || [urlText isEqual: @"vk.com"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_GENERIC", @"")
                                                        message:NSLocalizedString(@"ERROR_INSTANCE_URL_VKCOM_UNSUPPORTED", @"")
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil,nil];
        [alert show];
    } else if (![urlText isEqual: @""]) {
        NSMutableArray *instances = [[NSUserDefaults.standardUserDefaults arrayForKey:@"instances"] mutableCopy];
        [instances addObject:@{@"serverURL": urlText, @"isHTTPS": [NSNumber numberWithInt:[self HTTPSSwitch].on]}];
     
        [NSUserDefaults.standardUserDefaults setValue:instances forKey:@"instances"];
     
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_GENERIC", @"")
                                                        message:NSLocalizedString(@"ERROR_INSTANCE_URL_EMPTY_DESC", @"")
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil,nil];
        [alert show];
    }
}

- (void)viewDidUnload {
    [self setURLField:nil];
    [self setHTTPSSwitch:nil];
    [super viewDidUnload];
}
@end
