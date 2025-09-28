//
//  InstancesViewController.m
//  OpenVK Me
//
//  Created by miles on 16/08/22.
//  Copyright (c) 2022 Miles Prower. All rights reserved.
//

#import "InstancesViewController.h"

@interface InstancesViewController ()<UITableViewDataSource,UITableViewDelegate> {
    NSArray *instancesArray;
    NSInteger selectedInstance;
}

@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation InstancesViewController

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

    instancesArray = [NSUserDefaults.standardUserDefaults arrayForKey:@"instances"];
    selectedInstance = [NSUserDefaults.standardUserDefaults integerForKey:@"selectedInstance"];

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - UITableView DataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of sections.
    return instancesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *current = instancesArray[indexPath.row];
    
    cell.textLabel.text = [current valueForKey:@"serverURL"];
    if (selectedInstance == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:selectedInstance inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    [NSUserDefaults.standardUserDefaults setInteger:indexPath.row forKey:@"selectedInstance"];
    
    cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    selectedInstance = indexPath.row;

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        instancesArray = [NSUserDefaults.standardUserDefaults arrayForKey:@"instances"];
        [self.tableView reloadData];
    });
}

- (void)viewDidUnload {
    [self setTable:nil];
    [super viewDidUnload];
}
@end
