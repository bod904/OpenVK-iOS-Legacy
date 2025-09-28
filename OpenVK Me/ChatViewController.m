//
//  ChatViewController.m
//  OpenVK Me
//
//  Created by miles on 25/08/22.
//  Copyright (c) 2022 Miles Prower. All rights reserved.
//

#import "ChatViewController.h"
#import "APICommunicator.h"
#import "MessageCell.h"
#import <QuartzCore/QuartzCore.h>

#import "TRMalleableFrameView.h"

@interface ChatViewController () {
    NSDictionary *conversation;
    NSString *name;
    
    NSArray *messagesArray;
    NSInteger position;
}
@property (weak, nonatomic) IBOutlet UITextField *messageText;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *avatar;

@end

@implementation ChatViewController

@synthesize peerId;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.toolbar setBackgroundImage:[UIImage imageNamed:@"MessageEntryBackground"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"send_button"] forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"send_button_hl"] forState:UIControlStateHighlighted];
    [self.messageText.layer setCornerRadius:self.messageText.frame.size.height/2];
    [self.messageText.layer setBorderWidth:1.0f];
    [self.messageText.layer setBorderColor:[[UIColor colorWithRed:168.0/255.0 green:176.0/255.0 blue:184.0/255.0 alpha:1.0] CGColor]];
    self.messageText.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.messageText.leftViewMode = UITextFieldViewModeAlways;
    self.messageText.clipsToBounds = YES;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    conversation = [APICommunicator getConversationInfo:peerId];
    
    NSPredicate *pP = [NSPredicate predicateWithFormat:@"SELF.id = %d", peerId];
    NSDictionary *currentProfile = [[conversation objectForKey:@"profiles"] filteredArrayUsingPredicate:pP].count > 0 ? [[conversation objectForKey:@"profiles"] filteredArrayUsingPredicate:pP][0] : nil;

    self.title = [@"" stringByAppendingFormat:@"%@ %@", [currentProfile objectForKey:@"first_name"], [currentProfile objectForKey:@"last_name"]];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *urlAvatar = [NSURL URLWithString:[currentProfile objectForKey:@"photo_50"]];
        NSData *dataAvatar = [NSData dataWithContentsOfURL:urlAvatar];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.avatar setBackgroundImage:[UIImage imageWithData:dataAvatar] forState:UIControlStateNormal];
        });
    });
    
    int test = [[[[conversation objectForKey:@"items"][0] objectForKey:@"can_write"] objectForKey:@"allowed"] integerValue];
    
    self.sendButton.enabled = (bool)test;
    self.textMessage.enabled = (bool)test;
        
    messagesArray = [[NSMutableArray alloc] init];
    
    self.chatTableView.dataSource = self;
    self.chatTableView.delegate = self;
    
    [self appendMessages];
    [self.chatTableView reloadData];
    
    [self scrollToBottom:FALSE];
}

- (IBAction)sendMessage:(id)sender {
    if (![self.messageText.text isEqual:@""]) {
        self.sendButton.enabled = NO;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *response = [APICommunicator callMethod:@"messages.send" params:@[@[@"user_id", @(peerId)], @[@"message", self.messageText.text]]];
            if (response != nil) {
                NSString *messageId = [NSString stringWithFormat:@"%@", response];
                NSDictionary *messageDetails = [APICommunicator callMethod:@"messages.getById" params:@[@[@"message_ids", messageId]]];
            
                NSMutableArray *tmp = [messagesArray mutableCopy];
                NSArray *message = [messageDetails objectForKey:@"items"];
                [tmp addObjectsFromArray:message];
                messagesArray = tmp;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.chatTableView reloadData];
                    [self scrollToBottom:TRUE];
            
                    self.messageText.text = nil;
                    self.sendButton.enabled = YES;
                });
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_GENERIC", @"")
                                                            message:NSLocalizedString(@"ERROR_NO_RIGHTS", @"")
                                                           delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil,nil];
                [alert show];
                self.sendButton.enabled = YES;
            }
        });
    }
}

- (void)scrollToBottom:(bool)animated
{
    [self.chatTableView setContentOffset:CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height) animated:animated];
}

/* Both keyboardWillShow and keyboardWillHide i took from Discord Classic source code */

- (void)keyboardWillShow:(NSNotification *)notification {
	
	//thx to Pierre Legrain
	//http://pyl.io/2015/08/17/animating-in-sync-with-ios-keyboard/
	
	int keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
	float keyboardAnimationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
	int keyboardAnimationCurve = [[notification.userInfo objectForKey: UIKeyboardAnimationCurveUserInfoKey] integerValue];
    int tabbarHeight = self.tabBarController.tabBar.frame.size.height;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:keyboardAnimationDuration];
	[UIView setAnimationCurve:keyboardAnimationCurve];
	[UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRect frame = self.chatTableView.frame;
	frame.size.height = self.view.frame.size.height - keyboardHeight - self.toolbar.frame.size.height + tabbarHeight;
    
    self.chatTableView.frame = frame;
    
    CGRect frameT = self.toolbar.frame;
	frameT.origin.y = self.view.frame.size.height - keyboardHeight - self.toolbar.frame.size.height + tabbarHeight;
    self.toolbar.frame = frameT;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	
	float keyboardAnimationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
	int keyboardAnimationCurve = [[notification.userInfo objectForKey: UIKeyboardAnimationCurveUserInfoKey] integerValue];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:keyboardAnimationDuration];
	[UIView setAnimationCurve:keyboardAnimationCurve];
	[UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRect frame = self.chatTableView.frame;
	frame.size.height = self.view.frame.size.height - self.toolbar.frame.size.height;
    self.chatTableView.frame = frame;
    
    CGRect frameT = self.toolbar.frame;
	frameT.origin.y = self.view.frame.size.height - self.toolbar.frame.size.height;
    self.toolbar.frame = frameT;
	[UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setChatTableView:nil];
    [self setTextMessage:nil];
    [self setToolbar:nil];
    [self setMessageText:nil];
    [self setMessageText:nil];
    [self setSendButton:nil];
    [self setSendButton:nil];
    [self setAvatar:nil];
    [super viewDidUnload];
}

- (void)appendMessages {
    position++;
    NSDictionary *response = [APICommunicator callMethod:@"messages.getHistory" params:@[@[@"peer_id", @(peerId)], @[@"rev", @(1)]]];
    NSMutableArray *tmpC = [[NSMutableArray alloc] init];
    NSArray *tmpp = [response objectForKey:@"items"];
    [tmpC addObjectsFromArray:tmpp];
    [tmpC addObjectsFromArray:messagesArray];
    messagesArray = tmpC;
}

// Table cocksex

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return messagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MessageCell";
    MessageCell *cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
    NSDictionary *current = [messagesArray objectAtIndex:indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *bubble = [[UIImageView alloc] init];
    [cell.contentView addSubview:bubble];
    
    NSString *text = [current objectForKey:@"body"];
    
    NSInteger outMessage = [[current objectForKey:@"out"] integerValue];
    
    UIFont *font = [UIFont systemFontOfSize:16];
    CGSize size = [(text ? text : @"") sizeWithFont:font constrainedToSize:CGSizeMake(220, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat xText = (outMessage == 0) ? 22 - 5 : cell.frame.size.width - size.width - 14 - 5;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xText, 17 - 10, size.width, size.height)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = (text ? text : @"");
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    
    [cell.contentView addSubview:label];
    
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    CGFloat x = (outMessage == 0) ? 0 : cell.frame.size.width - width - 14 - 18;
    
    if (outMessage == 0) {
        bubble.image = [[UIImage imageNamed:@"Grey_Bubble.png"] stretchableImageWithLeftCapWidth:22 topCapHeight:14];
    } else {
        bubble.image = [[UIImage imageNamed:@"Blue_Bubble.png"] stretchableImageWithLeftCapWidth:17 topCapHeight:14];
    }
    
    bubble.frame = CGRectMake(x, 0, width + 18 + 18 - 5, height + 14 + 17 - 15);
    
    // Time
    NSDate *convTime = [NSDate dateWithTimeIntervalSince1970:[[current objectForKey:@"date"] intValue]];
    
    NSDateFormatter *convTimeF = [[NSDateFormatter alloc]init];
    [convTimeF setDateFormat:@"H:mm"];
    [convTimeF setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    UIFont *timeFont = [UIFont systemFontOfSize:14];
    
    CGSize timeSize = [[convTimeF stringFromDate:convTime] sizeWithFont:timeFont constrainedToSize:CGSizeMake(50, 50) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat xTime = (outMessage == 0) ? width + timeSize.width : cell.frame.size.width - width - timeSize.width - 35;
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(xTime, size.height - 10, timeSize.width, timeSize.height)];
    timeLabel.numberOfLines = 0;
    timeLabel.text = [convTimeF stringFromDate:convTime];
    timeLabel.font = timeFont;
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textColor =  [UIColor colorWithRed:153.0/255.0
                                    green:166.0/255.0
                                    blue:181.0/255.0
                                    alpha:1.0];
    timeLabel.textAlignment = UITextAlignmentRight;
    
    [cell.contentView addSubview:timeLabel];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *current = [messagesArray objectAtIndex:indexPath.row];
    NSString *text = [current objectForKey:@"body"];    
    UIFont *font = [UIFont systemFontOfSize:16];
    CGSize size = [(text ? text : @"") sizeWithFont:font constrainedToSize:CGSizeMake(220, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    
    return (CGFloat)(size.height + (18 - 10) * 2);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
@end
