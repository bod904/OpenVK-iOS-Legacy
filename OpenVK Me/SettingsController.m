//
//  SettingsController.m
//  OpenVK Me
//
//  Created by miles on 21/08/22.
//  Copyright (c) 2022 Miles Prower. All rights reserved.
//

#import "SettingsController.h"
#import "APICommunicator.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"

@interface SettingsController ()

@end

@implementation SettingsController

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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *info = [APICommunicator getCurrentUserInfo];
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSURL *url = [NSURL URLWithString:[info objectForKey:@"photo_100"]];
            [self.avatar setImageWithURL:url placeholderImage:[UIImage imageNamed:@"openvk-logo.png"]];
            self.name.text = [@"" stringByAppendingFormat:@"%@ %@", [info objectForKey:@"first_name"], [info objectForKey:@"last_name"]];
        });
    });

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == 5) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LOGOUT_DIALOG_TITLE", @"")
                                                        message:NSLocalizedString(@"LOGOUT_DIALOG_DESC", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"LOGOUT_DIALOG_NO", @"")
                                              otherButtonTitles:NSLocalizedString(@"LOGOUT_DIALOG_YES", @""),nil];
        alert.tag = 5;
        [alert show];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 5) {
        if (buttonIndex == 1)
        {
            [NSUserDefaults.standardUserDefaults setValue:nil forKey:@"token"];
            [NSUserDefaults.standardUserDefaults setValue:nil forKey:@"userID"];
            [self performSegueWithIdentifier:@"backToLogin" sender:nil];
        }
    }
}

- (void)viewDidUnload {
    [self setAvatar:nil];
    [self setName:nil];
    [super viewDidUnload];
}
@end
