//
//  PostComposeController.m
//  OpenVK
//
//  Created by miles on 03/03/23.
//  Copyright (c) 2023 Miles Prower. All rights reserved.
//

#import "PostComposeController.h"
#import "APICommunicator.h"

@interface PostComposeController ()

@end

@implementation PostComposeController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButton:(id)sender {    
    NSDictionary *response = [APICommunicator callMethod:@"Wall.post" params:@[@[@"message", self.postText.text], @[@"owner_id", [NSUserDefaults.standardUserDefaults stringForKey:@"userID"]]]];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setPostText:nil];
    [super viewDidUnload];
}
@end
