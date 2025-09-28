//
//  ConversationsController.m
//  OpenVK Me
//
//  Created by miles on 21/08/22.
//  Copyright (c) 2022 Miles Prower. All rights reserved.
//

#import "ConversationsController.h"
#import "APICommunicator.h"
#import "ConversationCell.h"
#import "SVPullToRefresh.h"
#import "ChatViewController.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"

@interface ConversationsController () {
    NSArray *conversationsArray;
    NSArray *profilesArray;
    NSInteger position;
    
    // For Seque
    NSInteger peerId;
}

@end

@implementation ConversationsController

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

    position = 0;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [self updateConversations];
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [self loadMore];
    }];
    
    [self.tableView triggerPullToRefresh];
}

- (void)updateConversations
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        position = 0;
        NSDictionary *response = [APICommunicator callMethod:@"messages.getConversations" params:@[@[@"count", @"10"], @[@"offset", [@(position) stringValue]], @[@"extended", @"1"], @[@"fields", @"photo_100"]]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            conversationsArray = [response objectForKey:@"items"];
            profilesArray = [response objectForKey:@"profiles"];
            [self.tableView reloadData];
            [self.tableView.pullToRefreshView stopAnimating];
        });
    });
}

- (void)loadMore
{
    position++;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *response = [APICommunicator callMethod:@"messages.getConversations" params:@[@[@"count", @"10"], @[@"offset", [@(position*10) stringValue]], @[@"extended", @"1"], @[@"fields", @"photo_100"]]];
        NSMutableArray *tmpC = [conversationsArray mutableCopy];
        [tmpC addObjectsFromArray:[response objectForKey:@"items"]];
        conversationsArray = tmpC;
    
        NSMutableArray *tmpP = [profilesArray mutableCopy];
        NSArray *newProfiles = [response objectForKey:@"profiles"];
        [tmpP removeObjectsInArray:newProfiles];
        [tmpP addObjectsFromArray:newProfiles];
        profilesArray = tmpP;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
    
            [self.tableView.infiniteScrollingView stopAnimating];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return conversationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ConversationCell";
    ConversationCell *cell = (ConversationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *current = [conversationsArray objectAtIndex:indexPath.row];
    
    NSPredicate *pP = [NSPredicate predicateWithFormat:@"SELF.id = %@", [[[current objectForKey:@"conversation"] objectForKey:@"peer"] objectForKey:@"id"]];
    NSDictionary *currentProfile = [profilesArray filteredArrayUsingPredicate:pP].count > 0 ? [profilesArray filteredArrayUsingPredicate:pP][0] : nil;
    
    if ([[[current objectForKey:@"last_message"] objectForKey:@"out"] isEqualToNumber:[NSNumber numberWithInt:1]])
    {
        cell.text.text = [@"" stringByAppendingFormat:@"%@ %@", @"You: ", [[current objectForKey:@"last_message"] objectForKey:@"text"]];
    } else {
        cell.text.text = [[current objectForKey:@"last_message"] objectForKey:@"text"];
    }
    
    cell.name.text = [@"" stringByAppendingFormat:@"%@ %@", [currentProfile objectForKey:@"first_name"], [currentProfile objectForKey:@"last_name"]];
    NSURL *url = [NSURL URLWithString:[currentProfile objectForKey:@"photo_100"]];
    [cell.avatar setImageWithURL:url placeholderImage:[UIImage imageNamed:@"openvk-logo.png"]];
    
    NSDate *convDate = [NSDate dateWithTimeIntervalSince1970:[[[current objectForKey:@"last_message"] objectForKey:@"date"] intValue]];
    
    NSDateFormatter *convDateF = [[NSDateFormatter alloc]init];
    [convDateF setDateFormat:@"d.LL.yy"];
    [convDateF setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    if ([[convDateF stringFromDate:[NSDate date]] isEqualToString:[convDateF stringFromDate:convDate]])
    {
        [convDateF setDateFormat:@"H:mm"];
    }
    
    cell.time.text = [convDateF stringFromDate:convDate];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *tempPeerId = [[[[(NSMutableArray*)conversationsArray objectAtIndex:indexPath.row] objectForKey:@"conversation"] objectForKey:@"peer"] objectForKey:@"id"];
    peerId = [tempPeerId integerValue];
    [self performSegueWithIdentifier:@"GoToChat" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"GoToChat"]) {
        ChatViewController *controller = [segue destinationViewController];
        NSLog(@"Перешёл");
        controller.peerId = peerId;
    }
}

@end
