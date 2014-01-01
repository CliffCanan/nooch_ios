//
//  HistoryFlat.m
//  Nooch
//
//  Created by crks on 10/3/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "HistoryFlat.h"
#import "Home.h"
#import "Helpers.h"
#import <QuartzCore/QuartzCore.h>
#import "TransactionDetails.h"

@interface HistoryFlat ()
@property(nonatomic,strong) UISearchBar *search;
@property(nonatomic,strong) UITableView *list;
@property(nonatomic,strong) UIButton *completed;
@property(nonatomic,strong) UIButton *pending;
@property(nonatomic) BOOL completed_selected;
@end

@implementation HistoryFlat

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
    //30/12
    histArray=[[NSMutableArray alloc]init];
    histShowArrayCompleted=[[NSMutableArray alloc]init];
    histShowArrayPending=[[NSMutableArray alloc]init];
    listType=@"ALL";
    index=1;
    isStart=YES;
    //
    self.completed_selected = YES;
    
    UIButton *filter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [filter setStyleClass:@"label_filter"];
    [filter setTitle:@"Filter" forState:UIControlStateNormal];
    [filter addTarget:self action:@selector(FilterHistory:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *filt = [[UIBarButtonItem alloc] initWithCustomView:filter];
    [self.navigationItem setRightBarButtonItem:filt];
    
    self.list = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, [UIScreen mainScreen].bounds.size.height-80)];
    [self.list setStyleId:@"history"];
    [self.list setDataSource:self]; [self.list setDelegate:self]; [self.list setSectionHeaderHeight:0];
    [self.view addSubview:self.list]; [self.list reloadData];
    
    self.search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 40, 320, 40)];
    [self.search setStyleId:@"history_search"];
    [self.search setDelegate:self];
    self.search.searchBarStyle=UISearchBarIconClear;
    [self.view addSubview:self.search];
    
    /*self.completed =  [UIButton buttonWithType:UIButtonTypeRoundedRect]; self.pending = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.completed setFrame:CGRectMake(0, 0, 160, 40)]; [self.pending setFrame:CGRectMake(160, 0, 160, 40)];
    [self.completed setBackgroundColor:kNoochBlue]; [self.pending setBackgroundColor:kNoochGrayLight];
    [self.completed setTitle:@"COMPLETED" forState:UIControlStateNormal]; [self.pending setTitle:@"PENDING" forState:UIControlStateNormal];
    [self.completed setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; [self.pending setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.pending addTarget:self action:@selector(switch_to_pending) forControlEvents:UIControlEventTouchUpInside];
    [self.completed addTarget:self action:@selector(switch_to_completed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.completed.titleLabel setFont:kNoochFontMed]; [self.pending.titleLabel setFont:kNoochFontMed];
    [self.view addSubview:self.completed]; [self.view addSubview:self.pending];*/
    
    NSArray *seg_items = @[@"Completed",@"Pending"];
    UISegmentedControl *completed_pending = [[UISegmentedControl alloc] initWithItems:seg_items];
    [completed_pending setStyleId:@"history_segcontrol"];
    [completed_pending addTarget:self action:@selector(completed_or_pending:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:completed_pending];
    [completed_pending setSelectedSegmentIndex:0];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [self.view addSubview:spinner];
    [spinner stopAnimating];
    [spinner setHidden:YES];
    [self loadHist:@"ALL" index:index len:20];
    
   
}
-(void)FilterHistory:(id)sender{
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissFP:) name:@"dismissPopOver" object:nil];
    isHistFilter=YES;
    popSelect *popOver = [[popSelect alloc] init];
    popOver.title = nil;
    fp =  [[FPPopoverController alloc] initWithViewController:popOver];
    fp.border = NO;
    fp.tint = FPPopoverWhiteTint;
    fp.arrowDirection = FPPopoverArrowDirectionUp;
    fp.contentSize = CGSizeMake(200, 355);
    [fp presentPopoverFromPoint:CGPointMake(280, 45)];
    

}
-(void)dismissFP:(NSNotification *)notification{
      [fp dismissPopoverAnimated:YES];
    isSearch=NO;
    if (![listType isEqualToString:@"CANCEL"]) {
        histShowArrayCompleted=[[NSMutableArray alloc]init];
        histShowArrayPending=[[NSMutableArray alloc]init];

        isFilter=YES;
        index=1;
        [self loadHist:listType index:index len:20];
    }
    else
        isFilter=NO;
   // needsUpdating = YES;
   // newTransfers = 0;
    //isSearching=YES;
   // arrSearchedRecords=[[NSMutableArray alloc]init];
    //NSLog(@"%@",filterPick);
    
//    if ([filterPick isEqualToString:@"CANCEL"]) {
//        isSearching=NO;
//    }
//    else{
//        
//        [me histMore:filterPick sPos:index len:20];
//    }
    
}

-(void)loadHist:(NSString*)filter index:(int)ind len:(int)len{
    
    if (index!=1 || isFilter==YES) {
        [spinner setHidden:NO];
        [spinner startAnimating];
        

    }
    isSearch=NO;
    serve*serveOBJ=[serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName=@"hist";
    [serveOBJ histMore:filter sPos:ind len:len];
}
#pragma mark - transaction type switching
- (void) completed_or_pending:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if ([segmentedControl selectedSegmentIndex] == 0) {
        self.completed_selected = YES;
    }
    else
    {
        self.completed_selected = NO;
    }
    [self.list removeFromSuperview];
    [self.view addSubview:self.list];
    [self.list reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Recent";
    }else{
        return @"";
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake (10,0,200,30)];
    title.textColor = kNoochGrayDark;
    if (section == 0) {
        title.text = @"Recent";
    }else{
        title.text = @"";
    }
    [headerView addSubview:title];
    [headerView setBackgroundColor:[Helpers hexColor:@"f8f8f8"]];
    [title setBackgroundColor:[UIColor clearColor]];
    return headerView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.completed_selected) {
        
        return [histShowArrayCompleted count]+1;
    } else {
                return [histShowArrayPending count]+1;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    if ([cell.contentView subviews]){
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }

    

    if (self.completed_selected) {
        
        if ([histShowArrayCompleted count]>indexPath.row) {
            
                NSDictionary*dictRecord=[histShowArrayCompleted objectAtIndex:indexPath.row];
                if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]) {
                    UIView *indicator = [UIView new];
                    [indicator setStyleClass:@"history_sidecolor"];
                    
                    UILabel *amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                    [amount setBackgroundColor:[UIColor clearColor]];
                    [amount setTextAlignment:NSTextAlignmentRight];
                    [amount setFont:[UIFont fontWithName:@"Roboto-Medium" size:18]];
                    [amount setStyleClass:@"history_transferamount"];
                    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Withdraw"]) {
                         [amount setStyleClass:@"history_transferamount_neg"];
                         [indicator setStyleClass:@"history_sidecolor_neg"];
                        [amount setText:[NSString stringWithFormat:@"-$%@.00",[dictRecord valueForKey:@"Amount"] ]];
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Deposit"])
                    {
                        [amount setStyleClass:@"history_transferamount_pos"];
                         [indicator setStyleClass:@"history_sidecolor_pos"];
                        [amount setText:[NSString stringWithFormat:@"+$%@.00",[dictRecord valueForKey:@"Amount"] ]];
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Donation"])
                    {
                        [amount setStyleClass:@"history_transferamount_neg"];
                      [indicator setStyleClass:@"history_sidecolor_neg"];
                        [amount setText:[NSString stringWithFormat:@"-$%@.00",[dictRecord valueForKey:@"Amount"] ]];
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Received"])
                    {
                        [amount setStyleClass:@"history_transferamount_pos"];
                         [indicator setStyleClass:@"history_sidecolor_pos"];
                        [amount setText:[NSString stringWithFormat:@"+$%@.00",[dictRecord valueForKey:@"Amount"] ]];
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Sent"])
                    {
                        [amount setStyleClass:@"history_transferamount_neg"];
                       [indicator setStyleClass:@"history_sidecolor_neg"];
                        [amount setText:[NSString stringWithFormat:@"-$%@.00",[dictRecord valueForKey:@"Amount"] ]];
                    }
                    else
                    {
                        [amount setStyleClass:@"history_transferamount_pos"];
                         [indicator setStyleClass:@"history_sidecolor_pos"];
                        [amount setText:[NSString stringWithFormat:@"$%@.00",[dictRecord valueForKey:@"Amount"] ]];
                    }
//                    //if (indexPath.row == 0) {
//                       
//                        
//                        [amount setText:[NSString stringWithFormat:@"$%@.00",[dictRecord valueForKey:@"Amount"] ]];
//                       
//                    } else {
//                        [indicator setStyleClass:@"history_sidecolor_neg"];
//                        
//                        [amount setText:@"-$1.00"];
//                        [amount setStyleClass:@"history_transferamount_neg"];
//                    }
                    
                    [cell.contentView addSubview:amount];
                    [cell.contentView addSubview:indicator];
                    
                    UILabel *name = [UILabel new];
                    [name setStyleClass:@"history_cell_textlabel"];
                    [name setStyleClass:@"history_recipientname"];
                    [name setText:[dictRecord valueForKey:@"FirstName"]];
                    [cell.contentView addSubview:name];
                    UILabel *date = [UILabel new];
                    [date setStyleClass:@"history_datetext"];
                    [date setText:[dictRecord valueForKey:@"TransactionDate"]];
                    [cell.contentView addSubview:date];
                    UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 50, 50)];
                    pic.layer.borderColor = kNoochGrayDark.CGColor;
                    pic.layer.borderWidth = 1;
                    pic.layer.cornerRadius = 25;
                    pic.clipsToBounds = YES;
                    // [pic setStyleClass:@"history_userpics"];
                    [pic setStyleCSS:@"background-image : url(Preston.png)"];
                    [pic setImage:[UIImage imageNamed:@"Preston.png"]];
                    [cell.contentView addSubview:pic];
                    UILabel *updated_balance = [UILabel new];
                    [updated_balance setText:@"$50.00"];
                    [updated_balance setStyleClass:@"history_updatedbalance"];
                    [cell.contentView addSubview:updated_balance];
                }
            
            
        }
     else if (indexPath.row==[histShowArrayCompleted count]) {
         
          if(isEnd==YES)
         {
             UILabel *name = [UILabel new];
             [name setStyleClass:@"history_cell_textlabel"];
             [name setStyleClass:@"history_recipientname"];
             [name setText:@"No Records"];
             [cell.contentView addSubview:name];
                      }
         else if(isStart==YES)
         {
             
             UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
             activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2, cell.contentView.frame.size.height / 2);
             [activityIndicator startAnimating];
             [cell.contentView addSubview:activityIndicator];
         }
         else
         {
             if (isSearch) {
                 UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                 activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2, cell.contentView.frame.size.height / 2);
                 [activityIndicator startAnimating];
                 [cell.contentView addSubview:activityIndicator];
                 ishistLoading=YES;
                 index++;
                 [self loadSearchByName];
             }
             else
             {
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2, cell.contentView.frame.size.height / 2);
            [activityIndicator startAnimating];
            [cell.contentView addSubview:activityIndicator];
           ishistLoading=YES;
           index++;
           [self loadHist:listType index:index len:20];
             }
         }
        }
       
        }
    else
    {
        
        
        if ([histShowArrayPending count]>indexPath.row) {
           
                NSDictionary*dictRecord=[histShowArrayPending objectAtIndex:indexPath.row];
                if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"]) {
                    UIView *indicator = [UIView new];
                    [indicator setStyleClass:@"history_sidecolor"];
                    
                    UILabel *amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                    [amount setBackgroundColor:[UIColor clearColor]];
                    [amount setTextAlignment:NSTextAlignmentRight];
                    [amount setFont:[UIFont fontWithName:@"Roboto-Medium" size:18]];
                    [amount setStyleClass:@"history_pending_transferamount"];
                    
                    [indicator setStyleClass:@"history_sidecolor_neutral"];
                    [amount setStyleClass:@"history_transferamount_neutral"];
                    
                    
                    [amount setText:[NSString stringWithFormat:@"$%@.00",[dictRecord valueForKey:@"Amount"] ]];
                    [cell.contentView addSubview:amount];
                    [cell.contentView addSubview:indicator];
                    
                    
                    UILabel *name = [UILabel new];
                    [name setStyleClass:@"history_cell_textlabel"];
                    [name setStyleClass:@"history_recipientname"];
                    [name setText:[dictRecord valueForKey:@"FirstName"]];
                    [cell.contentView addSubview:name];
                    
                    
                    UILabel *date = [UILabel new];
                    [date setStyleClass:@"history_datetext"];
                    [date setText:[dictRecord valueForKey:@"TransactionDate"]];
                    [cell.contentView addSubview:date];
                    
                    
                    UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 50, 50)];
                    pic.layer.borderColor = kNoochGrayDark.CGColor;
                    pic.layer.borderWidth = 1;
                    pic.layer.cornerRadius = 25;
                    pic.clipsToBounds = YES;
                    // [pic setStyleClass:@"history_userpics"];
                    [pic setStyleCSS:@"background-image : url(Preston.png)"];
                    [pic setImage:[UIImage imageNamed:@"Preston.png"]];
                    [cell.contentView addSubview:pic];
                    UILabel *updated_balance = [UILabel new];
                    [updated_balance setText:@"$50.00"];
                    [updated_balance setStyleClass:@"history_updatedbalance"];
                    [cell.contentView addSubview:updated_balance];
                    
                    
                   
                }
            
           
            
        }
        else if (indexPath.row==[histShowArrayPending count]) {
           
            if(isEnd==YES)
            {
                UILabel *name = [UILabel new];
                [name setStyleClass:@"history_cell_textlabel"];
                [name setStyleClass:@"history_recipientname"];

                [name setText:@"No Records"];
                [cell.contentView addSubview:name];
                return cell;
            }
            else if(isStart==YES)
            {
                
                UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2, cell.contentView.frame.size.height / 2);
                [activityIndicator startAnimating];
                [cell.contentView addSubview:activityIndicator];
            }
           else
           {
               if (isSearch) {
                   UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                   activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2, cell.contentView.frame.size.height / 2);
                   [activityIndicator startAnimating];
                   [cell.contentView addSubview:activityIndicator];
                   ishistLoading=YES;
                   index++;
                   [self loadSearchByName];
               }
               else
               {
               // [self loadSearchByName];
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2, cell.contentView.frame.size.height / 2);
            [activityIndicator startAnimating];
            [cell.contentView addSubview:activityIndicator];
           ishistLoading=YES;
               
           index++;
           [self loadHist:listType index:index len:20];
               }
            }
        }
    }
    
       return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 70.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *transaction = [NSDictionary new];
    TransactionDetails *details = [[TransactionDetails alloc] initWithData:transaction];
    [self.navigationController pushViewController:details animated:YES];
}
#pragma mark - searching
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
     [searchBar setShowsCancelButton:NO];
    [self.search resignFirstResponder];
    //if ([searchBar.text length]>0) {
        isSearch=NO;
        isFilter=NO;
        listType=@"ALL";
        index=1;
        self.search.text=@"";
        [self.search resignFirstResponder];
        [self loadHist:listType index:index len:20];
    
   // }
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if ([searchBar.text length]>0) {
        listType=@"ALL";
        SearchStirng=self.search.text;
        histShowArrayCompleted=[[NSMutableArray alloc]init];
        histShowArrayPending=[[NSMutableArray alloc]init];
        index=1;
        isSearch=YES;
        isFilter=NO;
        [self loadSearchByName];
        
    }
    [self.search resignFirstResponder];
    }
-(void)loadSearchByName
{
    
        [spinner setHidden:NO];
        [spinner startAnimating];
    
    
    listType=@"ALL";
   
    serve*serveOBJ=[serve new];
    serveOBJ.tagName=@"search";
    [serveOBJ setDelegate:self];
    [serveOBJ histMoreSerachbyName:listType sPos:index len:20 name:SearchStirng];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar becomeFirstResponder];
    [searchBar setShowsCancelButton:YES];
}


 - (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    return YES;
    }
#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{  NSError *error;
    [spinner setHidden:YES];
    [spinner stopAnimating];
    if ([tagName isEqualToString:@"hist"]) {
        //[histArray removeAllObjects];
        NSLog(@"%@",result);
       histArray = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        NSLog(@"%d",[histArray count]);
        if ([histArray count]>0) {
            isEnd=NO;
            isStart=NO;
           
            for (NSDictionary*dict in histArray) {
                if ([[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]) {
                    [histShowArrayCompleted addObject:dict];
                }
            }
                       for (NSDictionary*dict in histArray) {
                if ([[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"]) {
                    [histShowArrayPending addObject:dict];
                }
            }
            NSLog(@"%@",histArray);
            NSLog(@"%@",histShowArrayPending);
            
        }
        else
        {
            isEnd=YES;
        }
        [self.list reloadData];
    }
    else if([tagName isEqualToString:@"search"]){
        //[histArray removeAllObjects];
        NSLog(@"%@",result);
        histArray = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        NSLog(@"%d",[histArray count]);
        if ([histArray count]>0) {
            isEnd=NO;
            isStart=NO;
            
            for (NSDictionary*dict in histArray) {
                if ([[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]) {
                    [histShowArrayCompleted addObject:dict];
                }
            }
            for (NSDictionary*dict in histArray) {
                if ([[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"]) {
                    [histShowArrayPending addObject:dict];
                }
            }
            NSLog(@"%@",histArray);
            NSLog(@"%@",histShowArrayPending);
            
        }
        else
        {
            isEnd=YES;
        }
        [self.list reloadData];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
