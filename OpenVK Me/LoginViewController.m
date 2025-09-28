//
//  LoginControllerViewController.m
//  OpenVK Me
//
//  Created by miles on 15/08/22.
//  Copyright (c) 2022 Miles Prower. All rights reserved.
//

#import "LoginViewController.h"
#import "APICommunicator.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *loginField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

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
    self.loginField.delegate = self;
    self.passwordField.delegate = self;
	// Do any additional setup after loading the view.
    
    BOOL firstStartup = [NSUserDefaults.standardUserDefaults boolForKey:@"firstStartup"];
    if (firstStartup == YES) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_VK_NOT_SUPPORTED_TITLE", @"")
                                                    message:NSLocalizedString(@"ERROR_VK_NOT_SUPPORTED_CONTENT", @"")
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil,nil];
        [alert show];
        [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"firstStartup"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}

- (IBAction)loginAction:(id)sender {
    [self login:nil];
}

- (void)login:(NSString *)twofa {
    NSString *message = [APICommunicator getToken:[self loginField].text password:[self passwordField].text twofaCode:twofa];
    if(message == nil) {
        message = NSLocalizedString(@"ERROR_INTERNET_PROBLEMS", @"");
    } else if ([message isEqual:@"invalid_password"]) {
        message = NSLocalizedString(@"ERROR_INCORRECT_LOGIN_OR_PASSWORD", @"");;
    } else if ([message isEqual:@"need_validation"]) {
        UIAlertView * twofaAlertView = [[UIAlertView alloc]
                                        initWithTitle:NSLocalizedString(@"ERROR_TWO_FACTOR_TITLE", @"") message:NSLocalizedString(@"ERROR_TWO_FACTOR_DESC", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"CANCEL", @""), nil];
        twofaAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        twofaAlertView.tag = 1;
        [twofaAlertView show];
    } else {
        message = nil;
    }
    
    if (message != nil) {
        if (![message isEqualToString:@"need_validation"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_GENERIC", @"")
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil,nil];
            [alert show];
        }
    } else {
        [self performSegueWithIdentifier:@"goToMain" sender:nil];
    }
}

// Alert

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 1) {
        if (buttonIndex == 0)
        {
            [self login:[alertView textFieldAtIndex:0].text];
        }
    }
}

@end
