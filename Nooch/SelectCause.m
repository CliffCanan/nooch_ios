//
//  SelectCause.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "SelectCause.h"
#import "Home.h"
#import "UIImageView+WebCache.h"
#import "CharityDetails.h"

@interface SelectCause ()
@property(nonatomic,strong) UITableView *list;
@property(nonatomic,strong) UISearchBar *search;
@end

@implementation SelectCause

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
    
    [self.navigationItem setTitle:@"Select Cause"];
    
    serve*serveOBJ=[serve new];
    serveOBJ.tagName=@"featuredNp";
    serveOBJ.Delegate=self;
    [serveOBJ GetFeaturedNonprofit];
    
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.list = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, 320, [[UIScreen mainScreen] bounds].size.height - 196)];
    [self.list setDelegate:self]; [self.list setDataSource:self];
    
    [self.view addSubview:self.list]; [self.list reloadData];
    
    self.search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [self.search setDelegate:self];
    [self.view addSubview:self.search];
    
    UIButton *ribbon = [UIButton new];
    [ribbon setStyleId:@"nonprofit_ribbon_blue"];
    [self.view addSubview:ribbon];
    
   feat = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 130)];
    [feat setStyleClass:@"featured_nonprofit_banner"];
    [feat setStyleCSS:@"background-image : url(4k_image.png)"];
    [feat setImage:[UIImage imageNamed:@"4k_image.png"]];
    [self.view addSubview:feat];
    
    UIView *bar = [UIView new];
    [bar setStyleId:@"featured_nonprofit_label_background"];
    [self.view addSubview:bar];
    
    UILabel *featured = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, 320, 30)];
    [featured setAlpha:0.75]; [featured setText:@"    Featured Nonprofit"];
    [featured setStyleId:@"featured_nonprofit_label"];
    [self.view addSubview:featured];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        if (isSearching) {
            return [arrSearchedRecords count];
        }
        return [causesArr count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        
        [cell.textLabel setTextColor:kNoochGrayLight];
        cell.indentationLevel = 1; cell.indentationWidth = 60;
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        /*cell.textLabel.textColor = [UIColor colorWithRed:51./255.
         green:153./255.
         blue:204./255.
         alpha:1.0];*/
    }
    //29/12
    cell.contentView.tag=indexPath.row;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
    [pic setImage:[UIImage imageNamed:@"4KforCancer.png"]];
    [pic setStyleClass:@"nonprofitlist_pic"];
    //[pic setStyleCSS:@"background-image : 4KforCancer.png"];
    [cell addSubview:pic];
    if (isSearching) {
        
        cell.contentView.tag=indexPath.row;
        
        
        dict = [arrSearchedRecords objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"OrganizationName"]];
        
        if ([FeaturedcausesArr containsObject:dict]) {
            cell.detailTextLabel.text=@"Featured";
            
        }
        else
            cell.detailTextLabel.text=@"";
        [pic setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"PhotoIcon"]]
           placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
        
        //iv.image = [dict objectForKey:@"image"];
        [cell.contentView addSubview:pic];
        
        return cell;
    }

    
    dict = [causesArr objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"OrganizationName"]];
    if (indexPath.row<[FeaturedcausesArr count]) {
        cell.detailTextLabel.textColor=[UIColor blackColor];
        cell.detailTextLabel.text=@"Featured";
    }
    else
        cell.detailTextLabel.text=@"";
    
   
    
    [cell.textLabel setStyleClass:@"nonprofitlist_name"];
    if (![[dict valueForKey:@"PhotoIcon"] isKindOfClass:[NSNull class]]) {
        [pic setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"PhotoIcon"]]
           placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    }
    
   [cell.contentView addSubview:pic];
    
    return cell;

    //
//    UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
//    [pic setImage:[UIImage imageNamed:@"4KforCancer.png"]];
//    [pic setStyleClass:@"nonprofitlist_pic"];
//    [pic setStyleCSS:@"background-image : 4KforCancer.png"];
//    [cell addSubview:pic];
//    
//    [cell.textLabel setStyleClass:@"nonprofitlist_name"];
//    cell.textLabel.text = @"4K For Cancer";
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 70.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cause = [NSDictionary new];
    CharityDetails *charity = [[CharityDetails alloc] initWithReceiver:cause];
    NSString*strNonProfitid=[[causesArr objectAtIndex:indexPath.row] valueForKey:@"NonprofitId"];
    NSDictionary*dict=[NSDictionary dictionaryWithObjectsAndKeys:strNonProfitid,@"id",[[causesArr objectAtIndex:indexPath.row] valueForKey:@"OrganizationName"],@"OrganizationName", nil];
     dictnonprofitid=[dict mutableCopy];
    [self.navigationController pushViewController:charity animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    //29/12
    
    if ([tagName isEqualToString:@"featuredNp"]) {
        FeaturedcausesArr = [[NSMutableArray alloc]init];
        
        NSError* error;
        FeaturedcausesArr = [NSJSONSerialization
                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                        options:kNilOptions
                        error:&error];
        [feat setImageWithURL:[NSURL URLWithString:[[FeaturedcausesArr objectAtIndex:0] valueForKey:@"PhotoBanner"]]
                    placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
        
        serve*serveOBJ=[serve new];
        serveOBJ.tagName=@"NPList";
        serveOBJ.Delegate=self;
        [serveOBJ GetNonProfiltList];
    }
    else if ([tagName isEqualToString:@"NPList"]){
        causesArr=[[NSMutableArray alloc]init];
        // causesArr=[FeaturedcausesArr copy];
        for (NSDictionary*dict in FeaturedcausesArr) {
            [causesArr addObject:dict];
        }
          NSError* error;
        for (NSDictionary*dict in [NSJSONSerialization
                                   JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                   options:kNilOptions
                                   error:&error]) {
            [causesArr addObject:dict];
        }
       
        NSLog(@"%@",causesArr);
        [self.list reloadData];
        
    }
}
#pragma mark - searching
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    isSearching = NO;
    
    [self.list reloadData];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO];
    //newTransfersDecrement = newTransfers;
    [self.list reloadData];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    isSearching = YES;
    [searchBar becomeFirstResponder];
    // [searchBar becomeFirstResponder];
    [searchBar setShowsCancelButton:YES];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText length]>0) {
        SearchText = searchText;
        isSearching = YES;
         arrSearchedRecords =[[NSMutableArray alloc]init];
        [self searchTableView];
        [self.list reloadData];
    }
    else{
        isSearching=NO;
        [self.list reloadData];
    }
}
- (void) searchTableView
{
    [arrSearchedRecords removeAllObjects];
    for (NSMutableDictionary *tableViewBind in causesArr)
    {
        
        NSComparisonResult result = [[tableViewBind valueForKey:@"OrganizationName"] compare:SearchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [SearchText length])];
        if (result == NSOrderedSame)
        {
            [arrSearchedRecords addObject:tableViewBind];
        }
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
