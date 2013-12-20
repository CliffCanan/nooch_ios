//
//  LocationBasedSearchViewController.m
//  Nooch
//
//  Created by Charanjit Singh Bhalla on 15/11/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "LocationBasedSearchViewController.h"
#import "serve.h"
#import "core.h"
@interface LocationBasedSearchViewController ()
{
    UIView*loader;
    NSArray * json;
    core*me;
}
@property (strong, nonatomic) IBOutlet UITableView *mLocationtbl;


@end

@implementation LocationBasedSearchViewController

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
    
    serve * ser = [serve new];
    [ser setDelegate:self];
    [ser getLocationBasedSearch:@"2"];
    if (![self.view.subviews containsObject:loader]) {
        me=[core new];
        loader=[me waitStat:@"Loading info..."];
        
        [self.view addSubview:loader];
        [self.view bringSubviewToFront:loader];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)listen:(NSString *)result tagName:(NSString *)tagName {
    json = [result JSONValue];
    if (json.count !=0) {
        [self.mLocationtbl reloadData];
    }
    if ([self.view.subviews containsObject:loader]) {
        [loader removeFromSuperview];
        [me endWaitStat];
    }
    NSLog(@"JSON Is %@",json);
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
    tableView.rowHeight = 80;
    return json.count;
}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//
//
//    return view;
//
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LocationCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary * temp = [json objectAtIndex:indexPath.row];
    
    NSString * name = [NSString stringWithFormat:@"%@ %@",[temp objectForKey:@"FirstName"],[temp objectForKey:@"LastName"]];
    [cell.textLabel setText:name];
    
    NSString * miles;
    if ([[temp objectForKey:@"Miles"] intValue]<1) {
        miles = [NSString stringWithFormat:@"%d feet",([[temp objectForKey:@"Miles"] intValue] * 100)];
    }
    else
    {
        miles = [NSString stringWithFormat:@"%d miles",[[temp objectForKey:@"Miles"] intValue]];
        
    }
    
    
    [cell.detailTextLabel setText:miles];
    
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
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
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    
}


#pragma mark Navigation Controller back
- (IBAction)GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
