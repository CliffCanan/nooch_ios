//
//  popSelect.m
//  Nooch
//
//  Created by Preston Hults on 2/27/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "popSelect.h"
#import "HistoryFlat.h"
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
    popList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 250, 320)];
    [popList setRowHeight:40];
    if (memoList) {
        [popList setRowHeight:35];
        [popList setFrame:CGRectMake(0, 0, 300, 320)];
    }
    [popList setUserInteractionEnabled:YES];
    [popList setScrollEnabled:NO];
    [popList setDelegate:self];
    [popList setDataSource:self];
    [self.view addSubview:popList];
}

-(void)viewWillAppear:(BOOL)animated{
    [popList reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{  
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(memoList)
        return 6;
    else
        return 8;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];
    if (isHistFilter) {
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"ALL";
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"Sent";
        }else if(indexPath.row == 2){
            cell.textLabel.text = @"Received";
        }else if(indexPath.row == 3){
            cell.textLabel.text = @"Requests";
        }else if(indexPath.row == 4){
            cell.textLabel.text = @"Deposits";
        }else if(indexPath.row == 5){
            cell.textLabel.text = @"Withdrawals";
        }else if(indexPath.row == 6){
            cell.textLabel.text = @"Disputes";
        }else if(indexPath.row == 7){
            cell.textLabel.text = @"Cancel";
        }
        return cell;
    }
    if (!memoList) {
        //[cell.textLabel setFont:[core nFont:@"Medium" size:14.0]];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"ALL";
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"Sent";
        }else if(indexPath.row == 2){
            cell.textLabel.text = @"Received";
        }else if(indexPath.row == 3){
            cell.textLabel.text = @"Requests";
        }else if(indexPath.row == 4){
            cell.textLabel.text = @"Deposits";
        }else if(indexPath.row == 5){
            cell.textLabel.text = @"Withdrawals";
        }else if(indexPath.row == 6){
            cell.textLabel.text = @"Disputes";
        }else if(indexPath.row == 7){
            cell.textLabel.text = @"Cancel";
        }
        return cell;
    }else{
        //[cell.textLabel setFont:[core nFont:@"Medium" size:12.0]];
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(245, 7, 20, 20)];
        if (indexPath.row == 0) {
            [iv setImage:[UIImage imageNamed:@"Memo_Icon.png"]];
            cell.textLabel.text = @"Miscellaneous";
        }else if(indexPath.row == 1){
            [iv setImage:[UIImage imageNamed:@"MemoIconFoodSelected.png"]];
            cell.textLabel.text = @"Food";
        }else if(indexPath.row == 2){
            [iv setImage:[UIImage imageNamed:@"MemoIconTixSelected.png"]];
            cell.textLabel.text = @"Entertainment";
        }else if(indexPath.row == 3){
            [iv setImage:[UIImage imageNamed:@"MemoIconUtilitiesSelected.png"]];
            cell.textLabel.text = @"Utilities";
        }else if(indexPath.row == 4){
            [iv setImage:[UIImage imageNamed:@"MemoIconIOUselected.png"]];
            cell.textLabel.text = @"IOU";
        }else if(indexPath.row == 5){
            [iv setImage:[UIImage imageNamed:@"MemoIconCancelSelected.png"]];
            cell.textLabel.text = @"Cancel";
        }
        [cell.contentView addSubview:iv];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isHistFilter) {
        if (indexPath.row == 0) {
         listType = @"ALL";
         }else if(indexPath.row == 1){
         listType = @"SENT";
         }else if(indexPath.row == 2){
         listType = @"RECEIVED";
         }else if(indexPath.row == 3){
         listType = @"REQUEST";
         }else if(indexPath.row == 4){
         listType = @"DEPOSIT";
         }else if(indexPath.row == 5){
         listType = @"WITHDRAW";
         }else if(indexPath.row == 6){
             listType = @"DISPUTED";}
        else if(indexPath.row == 7){
        listType = @"CANCEL";
         }
        isFilterSelected=YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissPopOver" object:nil];
  return;
    }
    if (!memoList) {
        
        /*if (indexPath.row == 0) {
            filterPick = @"ALL";
        }else if(indexPath.row == 1){
            filterPick = @"SENT";
        }else if(indexPath.row == 2){
            filterPick = @"RECEIVED";
        }else if(indexPath.row == 3){
            filterPick = @"REQUEST";
        }else if(indexPath.row == 4){
            filterPick = @"DEPOSIT";
        }else if(indexPath.row == 5){
            filterPick = @"WITHDRAW";
        }else if(indexPath.row == 6){
            filterPick = @"DISPUTED";
        }*/
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"dismissPopOver" object:nil];
        return;
    }else{
        NSString *selectedImg = [NSString new];
        NSString *selectedCat = [NSString new];
        if (indexPath.row == 0) {
            selectedImg= @"Memo_Icon.png";
            selectedCat = @"0dm";
        }else if(indexPath.row == 1){
            selectedImg = @"MemoIconFoodSelected.png";
            selectedCat = @"0fm";
        }else if(indexPath.row == 2){
            selectedImg=@"MemoIconTixSelected.png";
            selectedCat = @"0tm";
        }else if(indexPath.row == 3){
            selectedImg=@"MemoIconUtilitiesSelected.png";
            selectedCat = @"0um";
        }else if(indexPath.row == 4){
            selectedImg= @"MemoIconIOUselected.png";
            selectedCat= @"0im";
        }else if(indexPath.row == 5){
            selectedImg= @"CANCELLED";
            selectedCat = @"";
        }
        NSMutableDictionary *selectedMemo = [NSMutableDictionary new];
        [selectedMemo setObject:selectedImg forKey:@"img"];
        [selectedMemo setObject:selectedCat forKey:@"cat"];
        memoList = NO;
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"dismissPopOver" object:self userInfo:selectedMemo];
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
