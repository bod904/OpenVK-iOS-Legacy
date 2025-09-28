//
//  LoginControllerViewController.h
//  OpenVK Me
//
//  Created by miles on 15/08/22.
//  Copyright (c) 2022 Miles Prower. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *loginView;

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
