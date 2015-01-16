//
//  popSelect.m
//  Nooch
//
//  Created by Preston Hults on 2/27/13.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import "popSelect.h"
#import "HistoryFlat.h"
#import "SetAptDetails.h"
@interface popSelect ()

@end

@implementation popSelect

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
    popList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 250, 290)];
    [popList setRowHeight:44];
    [popList setUserInteractionEnabled:YES];
    [popList setScrollEnabled:NO];
    [popList setDelegate:self];
    [popList setDataSource:self];
    [self.view addSubview:popList];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [popList reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Roboto-light" size:15]];

    if (isHistFilter)
    {
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"All Transfers";
        } else if(indexPath.row == 1) {
            cell.textLabel.text = @"Sent";
        } else if(indexPath.row == 2) {
            cell.textLabel.text = @"Received";
        } else if(indexPath.row == 3) {
            cell.textLabel.text = @"Requests";
        } else if(indexPath.row == 4) {
            cell.textLabel.text = @"Disputes";
        } else if(indexPath.row == 5) {
            cell.textLabel.text = @"Cancel";
        }
        return cell;
    }
    else if (isAutoPayPopoverShowing)
    {
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];

        if (indexPath.row == 0) {
            cell.textLabel.text = @"First Day of Month";
        } else if(indexPath.row == 1) {
            cell.textLabel.text = @"Last Day of Month";
        } else if(indexPath.row == 2) {
            cell.textLabel.text = @"Custom Day";
        } else if(indexPath.row == 3) {
            cell.textLabel.textColor = kNoochRed;
            cell.textLabel.text = @"Cancel";
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isHistFilter)
    {
        if (indexPath.row == 0) {
            listType = @"ALL";
        }
        else if(indexPath.row == 1){
            listType = @"SENT";
        }
        else if(indexPath.row == 2){
            listType = @"RECEIVED";
        }
        else if(indexPath.row == 3){
            listType = @"REQUEST";
        }
        else if(indexPath.row == 4){
            listType = @"DISPUTED";
        }
        else if(indexPath.row == 5){
            listType = @"CANCEL";
        }
        isFilterSelected = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissPopOver" object:nil];

        return;
    }
    else if (isAutoPayPopoverShowing)
    {
        if (indexPath.row == 0) {
            autoPaySetting = @"1st Day of Month";
        }
        else if (indexPath.row == 1){
            autoPaySetting = @"Last Day of Month";
        }
        else if (indexPath.row == 2){
            autoPaySetting = @"Custom";
        }
        else if (indexPath.row == 3){
            autoPaySetting = @"CANCEL";
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissPopOver" object:nil];
    }
    if (!memoList) {
        return;
    }
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
