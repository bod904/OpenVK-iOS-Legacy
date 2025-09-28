//
//  FriendsViewController.m
//  OpenVK Me
//
//  Created by miles on 18/08/22.
//  Copyright (c) 2022 Miles Prower. All rights reserved.
//

#import "FriendsViewController.h"
#import "APICommunicator.h"
#import "FriendCell.h"
#import "SVPullToRefresh.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"

@interface FriendsViewController () {
    NSArray *friendsArray;
    NSInteger friendsCount;
    NSInteger position;
}

@end

@implementation FriendsViewController

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
    
    [self.tableView.infiniteScrollingView startAnimating];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        position = 0;
        NSDictionary *response = [APICommunicator callMethod:@"friends.get" params:@[@[@"user_id", [NSUserDefaults.standardUserDefaults stringForKey:@"userID"]], @[@"count", @"15"], @[@"offset", [@(position) stringValue]], @[@"fields", @"photo_100"]]];
        friendsArray = [response objectForKey:@"items"];
        friendsCount = [[response objectForKey:@"count"] integerValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView addInfiniteScrollingWithActionHandler:^{
                if (friendsArray.count < friendsCount) {
                    [self loadMore];
                } else {
                    self.tableView.showsInfiniteScrolling = NO;
                }
            }];
            
            [self.tableView reloadData];
        });
    });
}

- (void)loadMore
{
    position++;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *response = [APICommunicator callMethod:@"friends.get" params:@[@[@"user_id", [NSUserDefaults.standardUserDefaults stringForKey:@"userID"]], @[@"count", @"15"], @[@"offset", [@(position) stringValue]], @[@"fields", @"photo_100"]]];
        NSMutableArray *tmpF = [friendsArray mutableCopy];
        [tmpF addObjectsFromArray:[response objectForKey:@"items"]];
        friendsArray = tmpF;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
    
            [self.tableView.infiniteScrollingView stopAnimating];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return friendsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    FriendCell *cell = (FriendCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *current = [friendsArray objectAtIndex:indexPath.row];
    cell.name.text = [@"" stringByAppendingFormat:@"%@ %@", [current objectForKey:@"first_name"], [current objectForKey:@"last_name"]];
    
    NSURL *url = [NSURL URLWithString:[current objectForKey:@"photo_100"]];
    [cell.avatar setImageWithURL:url placeholderImage:[UIImage imageNamed:@"openvk-logo.png"]];
    [cell.avatar setNeedsDisplay];
        
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
