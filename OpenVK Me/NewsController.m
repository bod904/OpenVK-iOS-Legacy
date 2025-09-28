//
//  NewsController.m
//  OpenVK
//
//  Created by miles on 03/03/23.
//  Copyright (c) 2023 Miles Prower. All rights reserved.
//

#import "NewsController.h"
#import "PostCell.h"
#import "APICommunicator.h"
#import "SVPullToRefresh.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"

@interface NewsController () {
    NSArray *news;
    NSArray *profiles;
    NSArray *groups;
    NSString *nextString;
}

@end

@implementation NewsController

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
    [self.tableView registerNib:[UINib nibWithNibName:@"PostCell" bundle:nil] forCellReuseIdentifier:@"postCell"];
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [self getNewsfeed];
    }];

    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [self loadMore];
    }];
    
    [self.tableView triggerPullToRefresh];
}

- (void)getNewsfeed
{
    dispatch_async(dispatch_get_global_queue(
        DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDictionary *newsfeedResponse = [APICommunicator getNewsfeed:@""];
            news = [newsfeedResponse valueForKey:@"items"];
            profiles = [newsfeedResponse valueForKey:@"profiles"];
            groups = [newsfeedResponse valueForKey:@"groups"];

            nextString = [newsfeedResponse valueForKey:@"next_from"];
        
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.tableView.pullToRefreshView stopAnimating];
            });
        }
    );
}

- (void)loadMore
{
    dispatch_async(dispatch_get_global_queue(
        DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDictionary *newsfeedResponse = [APICommunicator getNewsfeed:nextString];
            NSMutableArray *tmpP = [news mutableCopy];
            [tmpP addObjectsFromArray:[newsfeedResponse valueForKey:@"items"]];
            news = tmpP;

            NSMutableArray *tmpPr = [profiles mutableCopy];
            NSArray *newProfiles = [newsfeedResponse objectForKey:@"profiles"];
            [tmpPr removeObjectsInArray:newProfiles];
            [tmpPr addObjectsFromArray:newProfiles];
            profiles = tmpPr;

            NSMutableArray *tmpG = [profiles mutableCopy];
            NSArray *newGroups = [newsfeedResponse objectForKey:@"groups"];
            [tmpG removeObjectsInArray:newGroups];
            [tmpG addObjectsFromArray:newGroups];
            groups = tmpG;

            nextString = [newsfeedResponse valueForKey:@"next_from"];
        
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];

                [self.tableView.infiniteScrollingView stopAnimating];
            });
        }
    );
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)composeButton:(id)sender {
    [self performSegueWithIdentifier:@"goToPostCompose" sender:sender];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return news.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postCell" forIndexPath:indexPath];
    
    cell.text.text = [news[indexPath.row] valueForKey:@"text"];
    
    NSNumber *authorId = [news[indexPath.row] valueForKey:@"from_id"];
    if (authorId.doubleValue > 0) {
        NSPredicate *pP = [NSPredicate predicateWithFormat:@"SELF.id = %@", authorId];
        NSDictionary *currentProfile = [profiles filteredArrayUsingPredicate:pP].count > 0 ? [profiles filteredArrayUsingPredicate:pP][0] : nil;
        cell.name.text = [@"" stringByAppendingFormat:@"%@ %@", [currentProfile objectForKey:@"first_name"], [currentProfile objectForKey:@"last_name"]];
        NSURL *url = [NSURL URLWithString:[currentProfile objectForKey:@"photo_100"]];
        [cell.avatar setImageWithURL:url placeholderImage:[UIImage imageNamed:@"openvk-logo.png"]];
    } else {
        NSNumber *groupId = @(authorId.doubleValue * -1);
        NSPredicate *pP = [NSPredicate predicateWithFormat:@"SELF.id = %@", groupId];
        NSDictionary *currentGroup = [groups filteredArrayUsingPredicate:pP].count > 0 ? [groups filteredArrayUsingPredicate:pP][0] : nil;
        cell.name.text = [currentGroup objectForKey:@"name"];
        NSURL *url = [NSURL URLWithString:[currentGroup objectForKey:@"photo_100"]];
        [cell.avatar setImageWithURL:url placeholderImage:[UIImage imageNamed:@"openvk-logo.png"]];
    }
    
    NSDate *convDate = [NSDate dateWithTimeIntervalSince1970:[[news[indexPath.row] valueForKey:@"date"] doubleValue]];
    
    NSDateFormatter *convDateF = [[NSDateFormatter alloc]init];
    [convDateF setDateFormat:@"dd MMM YYYY HH:mm"];
    [convDateF setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    cell.date.text = [convDateF stringFromDate:convDate];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postCell"];
        
    CGSize header = cell.header.frame.size;
    CGSize text = [[news[indexPath.row] valueForKey:@"text"] sizeWithFont:cell.text.font constrainedToSize:CGSizeMake(cell.text.frame.size.width - 10, 9999) lineBreakMode:NSLineBreakByWordWrapping];

    CGFloat height = header.height + text.height + 18; // last number is padding
    return height;    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
