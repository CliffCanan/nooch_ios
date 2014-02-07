//
//  FundsMenu.m
//  Nooch
//
//  Created by crks on 10/3/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "FundsMenu.h"
#import "Home.h"
#import "Helpers.h"
#import "NewBank.h"
#import "NewCard.h"
#import "Deposit.h"
#import "Withdraw.h"
#import "BankVerification.h"
#import "ProfileInfo.h"
@interface FundsMenu ()
@property(nonatomic,strong)UITableView *menu;
@end

@implementation FundsMenu

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    self.menu = [[UITableView alloc] initWithFrame:CGRectMake(40, 64, 320, [[UIScreen mainScreen] bounds].size.height-64)];
    [self.menu setBackgroundColor:kNoochMenu]; [self.menu setDelegate:self]; [self.menu setDataSource:self]; [self.menu setSeparatorColor:kNoochLight];
    [self.menu setRowHeight:60];
    [self.menu setStyleId:@"rside_tableview"];
    [self.view addSubview:self.menu];
    [self.menu reloadData];
    self.menu.scrollEnabled = YES;
    UIView *user_bar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    [user_bar setBackgroundColor:kNoochMenu];
    [self.view addSubview:user_bar];
    
    UIImageView *nooch_n = [UIImageView new];
    [nooch_n setStyleId:@"rside_icon_n"];
    [self.view addSubview:nooch_n];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, 280, 40)];
    [name setStyleId:@"rside_balance"];
    if ([user objectForKey:@"Balance"]) {
        if ([[user objectForKey:@"Balance"] rangeOfString:@"."].location!=NSNotFound)
            [name setText:[NSString stringWithFormat:@"$%@",[user objectForKey:@"Balance"]]];
        else
            [name setText:[NSString stringWithFormat:@"$%@.00",[user objectForKey:@"Balance"]]];
    }
    else {
        [name setText:[NSString stringWithFormat:@"$%@",@"0.00"]];
    }
    [user_bar addSubview:name];
    
    UIButton *add_source = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [add_source setTitle:@"Add Funding Source" forState:UIControlStateNormal];
    [add_source addTarget:self action:@selector(add_source) forControlEvents:UIControlEventTouchUpInside];
    [add_source setBackgroundColor:kNoochGreen]; [add_source setTitleColor:kNoochLight forState:UIControlStateNormal];
    [add_source setFrame:CGRectMake(20, [UIScreen mainScreen].bounds.size.height - 60, 300, 60)];
    [add_source.titleLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:20]];
    [add_source setStyleClass:@"button_green"];
    [add_source setStyleId:@"buttons_addfundsource"];
    [self.view addSubview:add_source];
    //29/12
    
}

-(void)viewDidAppear:(BOOL)animated{
    isEditing=NO;
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:spinner];
    spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [spinner startAnimating];
    serve*serveOBJ=[serve new];
    serveOBJ.tagName=@"banks";
    serveOBJ.Delegate=self;
    [serveOBJ getBanks];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    arrWithrawalOptions=[[NSMutableArray alloc]init];
    
    isWithdrawalSelected=NO;
    
    [arrWithrawalOptions addObject:@"Add Funds"];
    
    [arrWithrawalOptions addObject:@"Withdraw Funds"];
    [arrWithrawalOptions addObject:@"Auto Cash Out"];
    
    self.menu.scrollEnabled = YES;
    NSLog(@"hmmmmmmm");
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    if (self.view.frame.origin.y==-160) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        //position off screen
        self.view.frame=CGRectMake(0, 0, 320, 568);
        [UIView commitAnimations];
        [textMyWithdrawal resignFirstResponder];
    }
    if ([SelectedOption isEqualToString:@"Triggers"]&&[on_off isOn]) {
        
        
        
        if ([dictSelectedWithdrawal count]==0) {
            
            SelectedOption=@"None";
            
        }
        
        if ([arrWithrawalOptions count]>3) {
            
            for (int i=0; i<countsubRecords; i++) {
                
                [arrWithrawalOptions removeLastObject];
                
            }
            [self.menu reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
        
    }
}

- (void) add_source
{
    if ([[assist shared]getSuspended]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
        
    }

    
    if (![[user valueForKey:@"Status"]isEqualToString:@"Active"] ) {
        
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Your are not a active user.Please click the link sent to your email." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
        
        
    }
    
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"ProfileComplete"]isEqualToString:@"YES"] ) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please validate your Profile before Proceeding." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
        [alert setTag:147];
        [alert show];
        return;
    }
    if ([ArrBankAccountCollection count]==2) {
        
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"NoochMoney" message:@"You can't add more than  2 Bank Accounts " delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
    }
    NewBank *add_bank = [NewBank new];
    [nav_ctrl pushViewController:add_bank animated:NO];
    [self.slidingViewController resetTopView];
    /* if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] ) {
     UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please validate your Phone Number before Proceeding." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
     [alert setTag:148];
     [alert show];
     return;
     }
     */
    //credit cards are disabled, but if ever readded the button is after Bank Account
    //UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Add Funding Source" message:@"Which type of account would you like to add?" //delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Bank Account", nil];
    //[av setTag:2];
    //[av show];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 23;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake (10,0,300,23)];
    [title setStyleClass:@"rside_section_header_text"];
    if (section == 0) {
        title.text = @"    FUNDS IN NOOCH";
    }else if(section == 1){
        title.text =  @"    MANAGE FUNDING SOURCES";
    }else if(section == 2){
        title.text = @"SOCIAL";
    }else if(section == 3){
        title.text = @"ABOUT";
    }else{
        title.text = @"";
    }
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 22, 320, 1)];
    [bottomLine setBackgroundColor:[UIColor blackColor]];
    //[headerView addSubview:bottomLine];
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [topLine setBackgroundColor:[UIColor blackColor]];
    [headerView addSubview:topLine];
    
    [headerView addSubview:title];
    [headerView setStyleClass:@"rside_sectionheader_bckgrnd"];
    [title setBackgroundColor:[UIColor clearColor]];
    return headerView;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"FUNDS IN NOOCH";
    }else if(section == 1){
        return @"MANAGE FUNDING SOURCES";
    }else if(section == 2){
        return @"SOCIAL";
    }else if(section == 3){
        return @"ABOUT";
    }else{
        return @"";
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    tableView.rowHeight=60.0f;
    if (section == 0) {
        if ([arrWithrawalOptions count]>3) {
            tableView.rowHeight=50.0f;
        }
        return [arrWithrawalOptions count];
    }else if(section == 1){
        return 4;
    }else{
        return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = kNoochGrayLight;
        cell.selectedBackgroundView = selectionColor;
    }
    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];
    cell.indentationLevel = 1;
    cell.indentationWidth = 30;
    cell.textLabel.textColor = [UIColor whiteColor];
    [cell setBackgroundColor:kNoochMenu];
    //[cell setBackgroundColor:[UIColor whiteColor]];
    cell.textLabel.font = [UIFont fontWithName:@"Roboto-Light" size:18];
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(24, 4, 32, 32)];
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(240, 17, 12, 18)];
    arrow.image = [UIImage imageNamed:@"Arrow.png"];
    if (indexPath.section == 0) {
        //cell.textLabel.font = [core nFont:@"Medium" size:18.0];
        if(indexPath.row == 0){
            [cell.contentView addSubview:arrow];
            cell.textLabel.text = @"Add Funds";
            [cell.textLabel setStyleClass:@"rtable_view_cell_textlabel_1"];
            [iv setStyleId:@"rside_icon_addfunds"];
            [cell.contentView addSubview:iv];
        }else if(indexPath.row == 1){
            [cell.contentView addSubview:arrow];
            cell.textLabel.text = @"Withdraw Funds";
            [cell.textLabel setStyleClass:@"rtable_view_cell_textlabel_1"];
            [iv setStyleId:@"rside_icon_wdfunds"];
            [cell.contentView addSubview:iv];
        }else if(indexPath.row == 2){
            cell.textLabel.text = [arrWithrawalOptions objectAtIndex:indexPath.row];
            [cell.textLabel setStyleClass:@"rtable_view_cell_textlabel_1"];
            [cell.detailTextLabel setStyleClass:@"rtable_view_cell_detailtext_1"];
            //cell.detailTextLabel.textColor=[UIColor whiteColor];
            
            on_off = [[UISwitch alloc] initWithFrame:CGRectMake(220, 5, 70, 30)];
            [on_off setStyleId:@"autowithdrawal_switch"];
            [cell.contentView addSubview:iv];
            on_off.tag=12000;
            if ([SelectedOption isEqualToString:@"Triggers"])
                
            {
                [on_off setOn:YES];
                
                if (dictSelectedWithdrawal) {
                    if ([dictSelectedWithdrawal valueForKey:SelectedOption]) {
                        NSString*option=[dictSelectedWithdrawal valueForKey:SelectedOption];
                        cell.detailTextLabel.textColor=[UIColor whiteColor];
                        UILabel*lbldetail=[[UILabel alloc]initWithFrame:CGRectMake(45, 35, 105, 15)];
                        lbldetail.backgroundColor=[UIColor clearColor];
                        lbldetail.textColor=[UIColor lightGrayColor];
                        lbldetail.text=[NSString stringWithFormat:@"%@",[dictSelectedWithdrawal valueForKey:option]];
                        lbldetail.font=[UIFont systemFontOfSize:12.0f];
                        [cell.contentView addSubview:lbldetail];
                        
                        
                        [cell.textLabel setStyleClass:@"rtable_view_cell_textlabel_1"];
                        //[cell.detailTextLabel setStyleClass:@"rtable_view_cell_detailtext_1"];
                        //   cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",[dictSelectedWithdrawal valueForKey:option]];
                        
                        SelectedSubOption=[dictSelectedWithdrawal valueForKey:option];
                    }
                }
                else{
                    cell.detailTextLabel.text=@"";
                    
                }}
            else if([SelectedOption isEqualToString:@"Frequency"]){
                if ([dictSelectedWithdrawal valueForKey:SelectedOption]) {
                    [on_off setOn:YES];
                }
                
                cell.detailTextLabel.text=@"";
                
            }
            else{
                [on_off setOn:NO];
                
                cell.detailTextLabel.text=@"";
            }
            
            [on_off addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
            
            [cell.contentView addSubview:on_off];
            
        }
        
        else{
            {
                if ([SelectedOption isEqualToString:@"Frequency"]) {
                    UIView*subV=[[UIView alloc]initWithFrame:CGRectMake(73, 5, 150, 40)];
                    subV.backgroundColor=[UIColor clearColor];
                    
                    UILabel*lbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 5, 150, 17)];
                    lbl.backgroundColor=[UIColor clearColor];
                    lbl.textColor=[UIColor whiteColor];
                    lbl.font=[UIFont systemFontOfSize:15.0f];
                    lbl.text=[arrWithrawalOptions objectAtIndex:indexPath.row];
                    [subV addSubview:lbl];
                    [cell.contentView addSubview:subV];
                    
                    UILabel*lblTime=[[UILabel alloc]initWithFrame:CGRectMake(0, 22, 105, 15)];
                    lblTime.backgroundColor=[UIColor clearColor];
                    lblTime.textColor=[UIColor lightGrayColor];
                    lblTime.text=strTimeFrequency;
                    lblTime.font=[UIFont systemFontOfSize:12.0f];
                    [cell.contentView addSubview:lblTime];
                    [subV addSubview:lblTime];
                    [cell.contentView addSubview:subV];
                    
                    
                    UIImageView*img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tickR.png"]];
                    img.frame=CGRectMake(25, 5, 32, 30);
                    [cell.contentView addSubview:img];
                    
                    cell.textLabel.text=Nil;
                    
                    if (!isEditing) {
                        
                        UIButton*edit=[UIButton buttonWithType:UIButtonTypeCustom];
                        
                        [edit  setTag:indexPath.row];
                        [edit setTintColor:[UIColor whiteColor]];
                        
                        // [edit setBackgroundColor:[UIColor blackColor]];
                        [edit setTitle:@"edit" forState:UIControlStateNormal];
                        [edit setStyleClass:@"reditbutton"];
                        [edit setFrame:CGRectMake(180, 5, 60, 30)];
                        
                        
                        
                        [edit addTarget:self action:@selector(editFrequency:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [cell.contentView addSubview:edit];
                        //[menuTable setEditing:!menuTable.editing animated:YES];
                    }
                    else{
                        UIButton*removeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
                        
                        [removeBtn  setTag:indexPath.row];
                        [removeBtn setTintColor:[UIColor whiteColor]];
                        //[removeBtn setBackgroundColor:[UIColor redColor]];
                        
                        [removeBtn setTitle:@"Remove" forState:UIControlStateNormal];
                        [removeBtn setFrame:CGRectMake(320, 5, 70, 35)];
                        [removeBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
                        [removeBtn addTarget:self action:@selector(RemoveFrequency:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [cell.contentView addSubview:removeBtn];
                        UIButton*cBtn=[UIButton buttonWithType:UIButtonTypeCustom];
                        
                        [cBtn  setTag:indexPath.row];
                        [cBtn setTintColor:[UIColor whiteColor]];
                        // [cBtn setBackgroundColor:[UIColor greenColor]];
                        [cBtn setTitle:@"Cancel" forState:UIControlStateNormal];
                        
                        [cBtn setFrame:CGRectMake(395, 5, 70, 35)];
                        [cBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
                        [cBtn addTarget:self action:@selector(CancelEdit:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [cell.contentView addSubview:cBtn];
                        
                        [UIView beginAnimations:nil context:nil];
                        
                        [UIView setAnimationDelegate:self];
                        [UIView setAnimationDuration:0.3];
                        subV.frame=CGRectMake(20, 5, 80, 35);
                        img.frame=CGRectMake(-40, 5, 40, 40);
                        [removeBtn setStyleClass:@"rremovebutton"];
                        [cBtn setStyleClass:@"rcancelbutton"];
                        [removeBtn setFrame:CGRectMake(125, 5, 70, 35)];
                        [cBtn setFrame:CGRectMake(200, 5, 70, 35)];
                        [UIView commitAnimations];
                        
                        
                    }
                    
                }
                else{
                    
                    cell.textLabel.text=[arrWithrawalOptions objectAtIndex:indexPath.row] ;
                    if (indexPath.row==7) {
                        
                        
                        textMyWithdrawal=[[UITextField alloc]initWithFrame:CGRectMake(70, 10, 70, 30)];
                        
                        
                        
                        [textMyWithdrawal setPlaceholder:@"Amount"];
                        
                        
                        
                        textMyWithdrawal.textColor = [UIColor blackColor];
                        
                        
                        
                        textMyWithdrawal.borderStyle = UITextBorderStyleRoundedRect;
                        
                        textMyWithdrawal.keyboardType=UIKeyboardTypeNumberPad ;
                        
                        textMyWithdrawal.font = [UIFont systemFontOfSize:15.0];
                        
                        
                        
                        [textMyWithdrawal setDelegate:self];
                        
                        
                        
                        textMyWithdrawal.backgroundColor = [UIColor whiteColor];
                        
                        
                        
                        [cell.contentView addSubview:textMyWithdrawal];
                        
                        
                        
                        Savebtn=[UIButton buttonWithType:UIButtonTypeCustom];
                        
                        
                        
                        [Savebtn  setTag:indexPath.row];
                        
                        [Savebtn setBackgroundColor:[UIColor greenColor]];
                        
                        [Savebtn setTitle:@"Save" forState:UIControlStateNormal];
                        
                        [Savebtn setFrame:CGRectMake(180, 5, 70, 35)];
                        [Savebtn setStyleClass:@"rsavebutton"];
                        [Savebtn addTarget:self action:@selector(saveAmtTrigger:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.contentView addSubview:Savebtn];
                        
                        
                    }
                    else
                    {
                        UIButton*check=[UIButton buttonWithType:UIButtonTypeCustom];
                        
                        [check  setTag:indexPath.row];
                        
                        if([dictSelectedWithdrawal valueForKey:[NSString stringWithFormat:@"%d",indexPath.row]])
                            
                        {
                            [check setImage:[UIImage imageNamed:@"tick.png"] forState:UIControlStateNormal];
                        }
                        
                        else{
                            [check setImage:[UIImage imageNamed:@"untick.png"] forState:UIControlStateNormal];
                        }
                        [check setStyleClass:@"rcheckmarkbutton"];
                        [check setFrame:CGRectMake(180, 5, 40, 40)];
                        
                        [check addTarget:self action:@selector(checkButtonCLicked:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [cell.contentView addSubview:check];
                        
                    }
                    
                }
                
                cell.detailTextLabel.text=@"";
                
            }
            [cell.textLabel setStyleClass:@"rtable_view_cell_textlabel_1"];
            [cell.detailTextLabel setStyleClass:@"rtable_view_cell_detailtext_1"];
        }
        //[cell.textLabel setStyleId:@"rside_table_cell_left"];
        
        //[cell.contentView addSubview:iv];
        
    }
    
    
    else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            NSLog(@"%d",[ArrBankAccountCollection count]);
            if ([ArrBankAccountCollection count] > 0) {
                [cell.contentView addSubview:arrow];
                NSDictionary *bank = [ArrBankAccountCollection objectAtIndex:0];
                //bank verified or Not
                //  NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
                // NSLog(@"%@",[[[me usr] objectForKey:@"banks"] objectAtIndex:0]);
                if ([ArrBankAccountCollection objectAtIndex:0]&&[[[ArrBankAccountCollection objectAtIndex:0] valueForKey:@"IsVerified"] intValue]==1&& [[[ArrBankAccountCollection objectAtIndex:0] valueForKey:@"IsPrimary"] intValue]==1 ) {
                    if ([[[ArrBankAccountCollection objectAtIndex:0] valueForKey:@"IsDeleted"] intValue]==0) {
                        [[assist shared]setBankVerified:YES];
                        //[defaults setObject:@"YES" forKey:@"IsPrimaryBankVerified"];
                        //[defaults synchronize];
                    }
                    else {
                        [[assist shared]setBankVerified:NO];
                        // [defaults setObject:@"NO" forKey:@"IsPrimaryBankVerified"];
                        // [defaults synchronize];
                    }
                }
                else {
                    [[assist shared]setBankVerified:NO];
                    // [defaults setObject:@"NO" forKey:@"IsPrimaryBankVerified"];
                    // [defaults synchronize];
                }
                
                //  NSLog(@"%@",[defaults valueForKey:@"IsPrimaryBankVerified"]);
                
                NSString*lastdigit=[NSString stringWithFormat:@"XXXX%@",[[bank objectForKey:@"BankAcctNumber"] substringFromIndex:[[bank objectForKey:@"BankAcctNumber"] length]-4]];
                cell.textLabel.text = [NSString stringWithFormat:@"   %@ %@",[bank objectForKey:@"BankName"],lastdigit];
                cell.textLabel.font=[UIFont fontWithName:@"Arial" size:12.0f];
                NSArray* bytedata = [bank valueForKey:@"BankPicture"];
                //XXXXXXXX2222
                unsigned c = bytedata.count;
                uint8_t *bytes = malloc(sizeof(*bytes) * c);
                
                unsigned i;
                for (i = 0; i < c; i++)
                {
                    NSString *str = [bytedata objectAtIndex:i];
                    int byte = [str intValue];
                    bytes[i] = (uint8_t)byte;
                }
                
                NSData *datos = [NSData dataWithBytes:bytes length:c];
                UIImageView*img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tickR.png"]];
                img.frame=CGRectMake(10, 10, 40 , 40);
                [cell.contentView addSubview:img];
                
                img.image = [UIImage imageWithData:datos];
                
                
            }else{
                // cell.userInteractionEnabled = NO;
                cell.textLabel.textColor = [core hexColor:@"adb1b3"];
                cell.textLabel.text = @"No Bank Accounts";
                iv.image = [UIImage imageNamed:@"Bank_Icon.png"];
            }
        }else if(indexPath.row == 1){
            if ([ArrBankAccountCollection count] == 2) {
                [cell.contentView addSubview:arrow];
                NSDictionary *bank = [ArrBankAccountCollection objectAtIndex:1];
                cell.textLabel.text = [NSString stringWithFormat:@"Account **** %@",[[bank objectForKey:@"BankAcctNumber"] substringFromIndex:[[bank objectForKey:@"BankAcctNumber"] length] -4]];
                iv.image = [UIImage imageNamed:@"Bank_Icon.png"];
                
            }
        }else if(indexPath.row == 2){
            if ([[[me usr] objectForKey:@"banks"] count] == 2 && [[[me usr] objectForKey:@"cards"] count] > 0) {
                [cell.contentView addSubview:arrow];
                NSDictionary *card = [[[me usr] objectForKey:@"cards"] objectAtIndex:0];
                cell.textLabel.text = [NSString stringWithFormat:@"Card **** %@",[[card objectForKey:@"CardNumber"] substringFromIndex:[[card objectForKey:@"CardNumber"] length] -4]];
                iv.image = [UIImage imageNamed:@"CreditCard_Icon.png"];
            }else if([[[me usr] objectForKey:@"banks"] count] == 1 && [[[me usr] objectForKey:@"cards"] count] == 2){
                [cell.contentView addSubview:arrow];
                NSDictionary *card = [[[me usr] objectForKey:@"cards"] objectAtIndex:1];
                cell.textLabel.text = [NSString stringWithFormat:@"Card **** %@",[[card objectForKey:@"CardNumber"] substringFromIndex:[[card objectForKey:@"CardNumber"] length] -4]];
                iv.image = [UIImage imageNamed:@"CreditCard_Icon.png"];
            }else if([[[me usr] objectForKey:@"banks"] count] == 2 && [[[me usr] objectForKey:@"cards"] count] == 0){
                //cell.userInteractionEnabled = NO;
                cell.textLabel.textColor = [core hexColor:@"adb1b3"];
                cell.textLabel.text = @"No Credit Cards";
                iv.image = [UIImage imageNamed:@"CreditCard_Icon.png"];
            }else{
                cell.textLabel.text = @"";
                // cell.userInteractionEnabled = NO;
            }
        }else if(indexPath.row == 3){
            if ([[[me usr] objectForKey:@"cards"] count] == 2 && [[[me usr] objectForKey:@"banks"] count] == 2){
                [cell.contentView addSubview:arrow];
                NSDictionary *card = [[[me usr] objectForKey:@"cards"] objectAtIndex:1];
                cell.textLabel.text = [NSString stringWithFormat:@"Card **** %@",[[card objectForKey:@"CardNumber"] substringFromIndex:[[card objectForKey:@"CardNumber"] length] -4]];
                iv.image = [UIImage imageNamed:@"CreditCard_Icon.png"];
            }else{
                cell.textLabel.text = @"";
                //cell.userInteractionEnabled = NO;
            }
            
        }
        //cell.textLabel.text=@"";
    }
    //[cell.contentView addSubview:iv];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.view.frame.origin.y==-160) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        //position off screen
        self.view.frame=CGRectMake(0, 0, 320, 568);
        [UIView commitAnimations];
        [textMyWithdrawal resignFirstResponder];
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if ([[assist shared]getSuspended]) {
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
                [alert show];
                return;
                
            }

            if (![[user valueForKey:@"Status"]isEqualToString:@"Active"] ) {
                
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Your are not a active user.Please click the link sent to your email." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
                [alert show];
                return;
                
                
            }
            NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
            if (![[defaults valueForKey:@"ProfileComplete"]isEqualToString:@"YES"] ) {
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please validate your Profile before Proceeding." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
                [alert setTag:147];
                [alert show];
                return;
            }
            
            if (![[defaults valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] ) {
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please validate your Phone Number before Proceeding." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
                [alert setTag:147];
                [alert show];
                return;
            }
            
            /* if (![[defaults valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] ) {
             UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please validate your Phone Number before Proceeding." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
             [alert setTag:147];
             [alert show];
             return;
             }*/
            
            if ([ArrBankAccountCollection count] == 0) {
                
                UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"Attach an Account" message:@"Before you can add funds you must attach a bank account." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Go Now", nil];
                [set setTag:201];
                [set show];
                return;
                
            }
            
            if (![[assist shared]isBankVerified]) {
                
                
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Verify Your Bank Account" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
                
                [alert show];
                
                return;
            }
            
            Deposit *dep = [[Deposit alloc]initWithData:ArrBankAccountCollection];
            [nav_ctrl pushViewController:dep animated:YES];
            [self.slidingViewController resetTopView];
            
        }else if(indexPath.row == 1){
            if ([[assist shared]getSuspended]) {
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
                [alert show];
                return;
                
            }

            if (![[user valueForKey:@"Status"]isEqualToString:@"Active"] ) {
                
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Your are not a active user.Please click the link sent to your email." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
                [alert show];
                return;
                
                
            }
            NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
            
            if (![[defaults valueForKey:@"ProfileComplete"]isEqualToString:@"YES"] ) {
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please validate your Profile before Proceeding." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
                [alert setTag:147];
                [alert show];
                return;
            }
            
            
            if (![[defaults valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] ) {
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please validate your Phone Number before Proceeding." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
                [alert setTag:147];
                [alert show];
                return;
            }
            
            /*   if (![[defaults valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] ) {
             UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please validate your Phone Number before Proceeding." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
             [alert setTag:147];
             [alert show];
             return;
             }*/
            
            if ([ArrBankAccountCollection count] == 0) {
                
                UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"Attach an Account" message:@"Before you can withdraw funds you must attach a bank account." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Go Now", nil];
                [set setTag:201];
                [set show];
                return;
                
            }
            
            
            if (![[assist shared]isBankVerified]) {
                
                
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Verify Your Bank Account" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
                
                [alert show];
                
                return;
            }
            
            Withdraw *wd = [[Withdraw alloc]initWithData:ArrBankAccountCollection];
            
            [nav_ctrl pushViewController:wd animated:YES];
            [self.slidingViewController resetTopView];
            
        }
        else if(indexPath.row==2){
//            if ([on_off isOn]&& [SelectedOption isEqualToString:@"Triggers"]) {
//                
//                if (isWithdrawalSelected) {
//                    
//                    isWithdrawalSelected=NO;
//                    
//                    if ([arrWithrawalOptions count]>3) {
//                        
//                        for (int i=0; i<countsubRecords; i++) {
//                            
//                            [arrWithrawalOptions removeLastObject];
//                            
//                        }
//                    }
//                    
//                    if (![dictSelectedWithdrawal valueForKey:SelectedOption]) {
//                        
//                        SelectedOption=@"None";
//                        
//                    }
//                }
//                
//                else if (!isWithdrawalSelected)
//                    
//                {
//                    isWithdrawalSelected=YES;
//                    
//                    temp = [dictSelectedWithdrawal allKeysForObject:SelectedSubOption];
//                    
//                    temp2=[dictSelectedWithdrawal allKeysForObject:[temp objectAtIndex:0]];
//                    
//                    if ([[temp2 objectAtIndex:0]isEqualToString:@"Triggers"])
//                        
//                    {
//                        countsubRecords=0;
//                        
//                        for (NSDictionary*dict in arrAutoWithdrawalT) {
//                            
//                            countsubRecords++;
//                            
//                            //  [arrWithrawalOptions addObject:[NSString stringWithFormat:@"%@ at %@",[dict valueForKey:@"Name"],[dict valueForKey:@"Time"]]];
//                            [arrWithrawalOptions addObject:[NSString stringWithFormat:@"At %@",[dict valueForKey:@"Name"]]];
//                            
//                        }
//                        
//                        [arrWithrawalOptions addObject:@"$"];
//                        
//                        countsubRecords++;
//                    }
//                    
//                }
//                [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
//                
//                // [tableView reloadData];
//                
//            }
            
        }
        
    }
    
    else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            if ([ArrBankAccountCollection count] > 0) {
                // Deposit *dep = [Deposit new];
                NSDictionary *bank = [ArrBankAccountCollection objectAtIndex:0];
                [[NSUserDefaults standardUserDefaults] setObject:[bank objectForKey:@"BankAccountId"] forKey:@"choice"];
                
                [self.slidingViewController resetTopView];
                
                BankVerification *bv=[BankVerification new];
                [nav_ctrl pushViewController:bv animated:YES];
                
                //[self.navigationController pushViewController:bv animated:YES];
                
            }
        }else if(indexPath.row == 1){
            if ([ArrBankAccountCollection count]==2) {
                // Deposit *dep = [Deposit new];
//                NSDictionary *bank = [ArrBankAccountCollection objectAtIndex:1];
//                [[NSUserDefaults standardUserDefaults] setObject:[bank objectForKey:@"BankAccountId"] forKey:@"choice"];
//                
//                [self.slidingViewController resetTopView];
//                BankVerification *bv=[BankVerification new];
//                [nav_ctrl pushViewController:bv animated:YES];
            }
            
        }else if(indexPath.row == 2){
            if ([[[me usr] objectForKey:@"banks"] count] == 2 && [[[me usr] objectForKey:@"cards"] count] > 0) {
                
            }else if([[[me usr] objectForKey:@"banks"] count] == 1 && [[[me usr] objectForKey:@"cards"] count] == 2){
                
            }
        }else if(indexPath.row == 3){
            if ([[[me usr] objectForKey:@"cards"] count] == 2 && [[[me usr] objectForKey:@"banks"] count] == 2){
                
            }
        }
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"banks: %d %d",[ArrBankAccountCollection count],buttonIndex);
    if (alertView.tag==147 && buttonIndex==1) {
        ProfileInfo *prof = [ProfileInfo new];
        [nav_ctrl pushViewController:prof animated:YES];
        [self.slidingViewController resetTopView];
        
    }
    else if (alertView.tag==148 && buttonIndex==1) {
        ProfileInfo *prof = [ProfileInfo new];
        [nav_ctrl pushViewController:prof animated:YES];
        [self.slidingViewController resetTopView];
        
    }
    else if (alertView.tag == 201){
        if (buttonIndex == 1) {
            
            NewBank *add_bank = [NewBank new];
            [nav_ctrl pushViewController:add_bank animated:NO];
            [self.slidingViewController resetTopView];
        }
    }
    
    else if (alertView.tag == 2){
        if (buttonIndex == 1) {
            if ([ArrBankAccountCollection count]==2) {
                
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"NoochMoney" message:@"You can't add more than  2 Bank Accounts " delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
                [alert show];
                return;
            }
            NewBank *add_bank = [NewBank new];
            [nav_ctrl pushViewController:add_bank animated:NO];
            [self.slidingViewController resetTopView];
        } else if (buttonIndex == 2){
            NewCard *add_card = [NewCard new];
            [nav_ctrl pushViewController:add_card animated:NO];
            [self.slidingViewController resetTopView];
        }
    }
    else if ([alertView tag]==12003) {
        
        if (buttonIndex==0) {
            
            SelectedOption=@"None";
            
            [on_off setOn:NO animated:YES];
            
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            
            
            
        }
        
        else if(buttonIndex==1)
            
        {
            
            SelectedOption=@"Frequency";
            
            
            [alertView dismissWithClickedButtonIndex:1 animated:YES];
            
            UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:Nil
                                                                     delegate:self
                                                            cancelButtonTitle:Nil
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:nil];
            
            
            int i;
            for (i=0; i<[arrAutoWithdrawalF count]; i++) {
                
                [actionSheet addButtonWithTitle:[[arrAutoWithdrawalF objectAtIndex:i]valueForKey:@"Name"]];
            }
            [actionSheet addButtonWithTitle:@"Cancel"];
            actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
            
            [actionSheet showInView:self.view];
            NSLog(@"Frequency");
            
        }
        
        else if (buttonIndex==2)
            
        {
            
            SelectedOption=@"Triggers";
            
            // [Switch setOn:YES animated:YES];
            
            if ([arrWithrawalOptions count]>3) {
                
                for (int i=0; i<countsubRecords; i++) {
                    
                    [arrWithrawalOptions removeLastObject];
                    
                }
                
            }
            
            countsubRecords=0;
            
            for (NSDictionary*dict in arrAutoWithdrawalT) {
                
                countsubRecords++;
                
                [arrWithrawalOptions addObject:[NSString stringWithFormat:@"At %@",[dict valueForKey:@"Name"]]];
                
                
                
            }
            
            [arrWithrawalOptions addObject:@"$"];
            
            countsubRecords++;
            
            [self.menu reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            
            
            
            
            [alertView dismissWithClickedButtonIndex:2 animated:YES];
            
            NSLog(@"Trigger");
            
            
            
        }
        
    }
    
    else if ([alertView tag]==12045)
        
    {
        if (buttonIndex==1) {
            
            UITextField *value = [alertView textFieldAtIndex:0];
            
            if ([value.text floatValue]<10 ||[value.text floatValue]>100 ) {
                
                //value.text=@"";
                
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"NoochMoney" message:@"Custom Withdrawal Between $10-$100" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                
                [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                
                [alert setTag:12045];
                
                [alert show];
            }
            
            else
                
            {
                if (!dictSelectedWithdrawal) {
                    
                    dictSelectedWithdrawal=[[NSMutableDictionary alloc]init];
                    
                }
                isWithdrawalSelected=YES;
                
                [dictSelectedWithdrawal removeAllObjects];
                
                [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%@ %@",[arrWithrawalOptions objectAtIndex:tagForFrequency],value.text]  forKey:[NSString stringWithFormat:@"%d",tagForFrequency]];
                
                [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%d",tagForFrequency] forKey:SelectedOption];
                
                NSLog(@"%@",dictSelectedWithdrawal);
                [spinner startAnimating];
                [spinner setHidden:NO];
                
                serve*serveOBJ=[serve new];
                
                serveOBJ.tagName=@"SaveWithdrawal";
                
                serveOBJ.Delegate=self;
                
                [serveOBJ SaveFrequency:[[arrAutoWithdrawalF objectAtIndex:tagForFrequency-3] valueForKey:@"Id"] type:@"Frequency" frequency:[value.text floatValue]];
                
                [self.menu reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                
            }
            
        }
        
    }
    
    
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    [spinner stopAnimating];
    [spinner setHidden:YES];
    NSLog(@"%@",arrWithrawalOptions);
    NSError* error;
    NSDictionary * DictResponse = [NSJSONSerialization
                                   JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                   options:kNilOptions
                                   error:&error];
    
    NSArray*arr=[NSJSONSerialization
                 JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                 options:kNilOptions
                 error:&error];
    
    if ([tagName isEqualToString:@"banks"]) {
        
        [spinner stopAnimating];
        [spinner setHidden:YES];
        if ([arr count]>0) {
            
            [[NSUserDefaults standardUserDefaults]
             setObject:@"1" forKey:@"IsBankAvailable"];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults]
             setObject:@"0" forKey:@"IsBankAvailable"];
            
        }
        ArrBankAccountCollection=[[NSMutableArray alloc]init];
        ArrBankAccountCollection=[arr mutableCopy];
        
        
        [self.menu reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [spinner startAnimating];
        [spinner setHidden:NO];
        
        serve*serveOBJ=[serve new];
        
        serveOBJ.tagName=@"withdrawOptions";
        
        [serveOBJ GetAllWithdrawalFrequency];
        
        serveOBJ.Delegate=self;
    }
    if ([tagName isEqualToString:@"selectedWithdrawal"]) {
        
        if ([DictResponse valueForKey:@"Result"]) {
            NSArray*arr=[[DictResponse valueForKey:@"Result"] componentsSeparatedByString:@","];
            if ([[arr objectAtIndex:2] isEqualToString:@"Frequency"]) {
                for (int i=0;i<arrAutoWithdrawalF.count;i++) {
                    NSDictionary*dict=[arrAutoWithdrawalF objectAtIndex:i];
                    if ([[dict valueForKey:@"Id"] isEqualToString:[arr objectAtIndex:0]]) {
                        isEditing=NO;
                        SelectedOption=@"Frequency";
                        if (!dictSelectedWithdrawal) {
                            dictSelectedWithdrawal=[[NSMutableDictionary alloc]init];
                        }
                        
                        isWithdrawalSelected=YES;
                        [dictSelectedWithdrawal removeAllObjects];
                        [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%@",[dict valueForKey:@"Name"]]forKey:[NSString stringWithFormat:@"%d",[arrAutoWithdrawalF indexOfObject:dict]]];
                        [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%d",[arrAutoWithdrawalF indexOfObject:dict]] forKey:SelectedOption];
                        strTimeFrequency=[dict valueForKey:@"Days"];
                        if ([strTimeFrequency isKindOfClass:[NSNull class]])
                        {
                            strTimeFrequency=@"(Last day @ 5PM)";
                        }
                        
                        else if ([strTimeFrequency isEqualToString:@"1,2,3,4,5"]) {
                            strTimeFrequency=@"(Mon-Fri @ 5PM)";
                        }
                        else if ([strTimeFrequency isEqualToString:@"5"]) {
                            strTimeFrequency=@"(Fri @ 5PM)";
                        }
                        countsubRecords=0;
                        countsubRecords++;
                        for (int i=3; i<[arrWithrawalOptions count]; i++) {
                            [arrWithrawalOptions removeObjectAtIndex:i];
                        }
                        
                        [arrWithrawalOptions addObject:[NSString stringWithFormat:@"%@",[dict valueForKey:@"Name"]]];
                        [self.menu reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                        // [self.menu reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
                        
                    }
                }
            }
            else if ([[arr objectAtIndex:2] isEqualToString:@"Trigger"]){
                if ([[arr objectAtIndex:0]isEqualToString:@""]) {
                    
                    
                    SelectedOption=@"Triggers";
                    if (!dictSelectedWithdrawal) {
                        
                        dictSelectedWithdrawal=[[NSMutableDictionary alloc]init];
                        
                    }
                    //isWithdrawalSelected=YES;
                    
                    [dictSelectedWithdrawal removeAllObjects];
                    [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"At $%@",[arr objectAtIndex:1]] forKey:@"custom"];
                    
                    [dictSelectedWithdrawal setValue:@"custom" forKey:SelectedOption];
                    [self.menu reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                }
                else{
                    for (int i=0;i<arrAutoWithdrawalT.count;i++) {
                        NSDictionary*dict=[arrAutoWithdrawalT objectAtIndex:i];
                        if ([[dict valueForKey:@"Id"] isEqualToString:[arr objectAtIndex:0]]) {
                            SelectedOption=@"Triggers";
                            if (!dictSelectedWithdrawal) {
                                
                                dictSelectedWithdrawal=[[NSMutableDictionary alloc]init];
                                
                            }
                            [dictSelectedWithdrawal removeAllObjects];
                            
                            [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"At $%@",[[arrAutoWithdrawalT objectAtIndex:[arrAutoWithdrawalT indexOfObject:dict]] valueForKey:@"AmountCredited"]] forKey:[NSString stringWithFormat:@"%d",[arrAutoWithdrawalT indexOfObject:dict]+3]];
                            
                            [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%d",[arrAutoWithdrawalT indexOfObject:dict]+3] forKey:SelectedOption];
                            [self.menu reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                            
                        }
                    }
                }
            }
            
        }
    }
    else if ([tagName isEqualToString:@"withdrawOptions"])
        
    {
        [spinner stopAnimating];
        [spinner setHidden:YES];
        
        // NSLog(@"response %@",[dictResult valueForKey:@"Result"]);
        arrAutoWithdrawalF=[[NSMutableArray alloc]init];
        arrAutoWithdrawalF=[arr mutableCopy];
        
        [spinner startAnimating];
        [spinner setHidden:NO];
        
        
        serve *serveOBJ=[serve new];
        
        serveOBJ.Delegate=self;
        
        serveOBJ.tagName=@"Triggers";
        
        [serveOBJ GetAllWithdrawalTrigger];
        
        
        
    }
    
    else if ([tagName isEqualToString:@"Triggers"])
        
    {
        [spinner stopAnimating];
        [spinner setHidden:YES];
        
        arrAutoWithdrawalT=[[NSMutableArray alloc]init];
        arrAutoWithdrawalT=[arr mutableCopy];
        [spinner startAnimating];
        [spinner setHidden:NO];
        
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"selectedWithdrawal";
        [serveOBJ getAutoWithDrawalSelectedOption];
        
        
        
        
        
    }
    else if ([tagName isEqualToString:@"AutoWithdrawalCancel"])
    {
        [spinner stopAnimating];
        [spinner setHidden:YES];
    }
    else if ([tagName isEqualToString:@"SaveWithdrawal"])
        
    {
        [spinner stopAnimating];
        [spinner setHidden:YES];
        
        NSError* error;
        dictResponse = [NSJSONSerialization
                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                        options:kNilOptions
                        error:&error];
        
        {
            
            if (isWithdrawalSelected) {
                
                isWithdrawalSelected=NO;
                
                if ([arrWithrawalOptions count]>3) {
                    
                    for (int i=0; i<countsubRecords; i++) {
                        
                        [arrWithrawalOptions removeLastObject];
                        
                    }
                }
                
                if (![dictSelectedWithdrawal valueForKey:SelectedOption]) {
                    
                    SelectedOption=@"None";
                    
                }
            }
            
            else if (!isWithdrawalSelected)
                
            {
                isWithdrawalSelected=YES;
                
                temp = [dictSelectedWithdrawal allKeysForObject:SelectedSubOption];
                
                temp2=[dictSelectedWithdrawal allKeysForObject:[temp objectAtIndex:0]];
                
                if ([[temp2 objectAtIndex:0]isEqualToString:@"Triggers"])
                    
                {
                    countsubRecords=0;
                    
                    for (NSDictionary*dict in arrAutoWithdrawalT) {
                        
                        countsubRecords++;
                        
                        //  [arrWithrawalOptions addObject:[NSString stringWithFormat:@"%@ at %@",[dict valueForKey:@"Name"],[dict valueForKey:@"Time"]]];
                        [arrWithrawalOptions addObject:[NSString stringWithFormat:@"At %@",[dict valueForKey:@"Name"]]];
                        
                    }
                    
                    [arrWithrawalOptions addObject:@"$"];
                    
                    countsubRecords++;
                }
                
            }
            [self.menu reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            // [tableView reloadData];
            
        }
        if ([[[dictResponse valueForKey:@"SaveFrequencyResult"] valueForKey:@"Result"]isEqualToString:@"Saved Successfully"]) {
            
        }
        
        else if([[[dictResponse valueForKey:@"SaveTriggersResult"] valueForKey:@"Result"]isEqualToString:@"Saved Successfully"])
            
        {
            
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:[[dictResponse valueForKey:@"SaveFrequencyResult"] valueForKey:@"Result"] delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            
            [alert show];
            
        }
        
        else
        {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:[[dictResponse valueForKey:@"SaveFrequencyResult"] valueForKey:@"Result"] delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            
            [alert show];
            
        }
        
    }
    
}
-(void)editFrequency:(id)sender{
    if (!isEditing) {
        isEditing=YES;
    }
    [self.menu reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)CancelEdit:(id)sender
{
    isEditing=NO;
    [self.menu reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}
-(void)RemoveFrequency:(id)sender{
    isEditing=NO;
    [on_off setOn:NO animated:YES];
    [arrWithrawalOptions removeLastObject];
    [dictSelectedWithdrawal removeAllObjects];
    [spinner startAnimating];
    [spinner setHidden:NO];
    
    serve*serveOBJ=[serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName=@"AutoWithdrawalCancel";
    [serveOBJ SaveFrequency:@"" type:@"" frequency:0];
    [self.menu reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}
-(void)saveAmtTrigger:(id)sender{
    
    [textMyWithdrawal resignFirstResponder];
    if (![textMyWithdrawal.text length]>0) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Enter Amount Between $10-$100" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
    }
    if ([textMyWithdrawal.text floatValue]<10 ||[textMyWithdrawal.text floatValue]>100 ) {
        
        textMyWithdrawal.text=@"";
        
        
        
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"NoochMoney" message:@"Enter Amount Between $10-$100" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        
        
        
        
        [alert show];
        return;
        
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    //position off screen
    self.view.frame=CGRectMake(0, 0, 320, 568);
    [UIView commitAnimations];
    if (!dictSelectedWithdrawal) {
        
        dictSelectedWithdrawal=[[NSMutableDictionary alloc]init];
        
    }
    
    isWithdrawalSelected=YES;
    
    [dictSelectedWithdrawal removeAllObjects];
    
    [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"$%@",textMyWithdrawal.text] forKey:[NSString stringWithFormat:@"%d",7]];
    
    [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%d",7] forKey:SelectedOption];
    //[dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%d",8] forKey:SelectedOption];
    
    
    NSLog(@"%@",dictSelectedWithdrawal);
    [spinner startAnimating];
    [spinner setHidden:NO];
    
    serve*serveOBJ=[serve new];
    
    serveOBJ.tagName=@"SaveWithdrawal";
    
    serveOBJ.Delegate=self;
    
    [serveOBJ SaveFrequency:@"" type:@"Tiggers" frequency:[textMyWithdrawal.text floatValue]];
    
    [self.menu reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}
- (void)changeSwitch:(UISwitch*)on_off1{
    int switch_tag=[on_off1 tag];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    if ([ArrBankAccountCollection count]==0)
    {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Add and Verify Your Bank Account To Enable Auto Cash Out" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil] ;
        [alert show];
        [on_off setOn:NO];
        return;
        
    }
    if (![[assist shared]isBankVerified]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Verify Your Bank Account To Enable Auto Cash Out" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil] ;
        [alert show];
        [on_off setOn:NO];
        return;
    }
    if (![[user valueForKey:@"Status"]isEqualToString:@"Active"] ) {
        
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Your are not a active user Please check your email." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        [on_off setOn:NO];
        return;
        
    }
    
    if (![[defaults valueForKey:@"ProfileComplete"]isEqualToString:@"YES"]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Complete Your Profile To Enable Auto Cash Out" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil] ;
        [alert show];
        [on_off setOn:NO];
        return;
    }
    
    if (switch_tag==12000) {
        
        if([on_off1 isOn]){
            
            isWithdrawalSelected=YES;
            NSLog(@"%@",arrWithrawalOptions);
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Withdrawal Options" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Frequency",@"Triggers", nil];
            
            [alert setTag:12003];
            
            
            
            [alert show];
            
            // Execute any code when the switch is ON
            
            NSLog(@"Switch is ON");
            
        }
        
        else{
            if (self.view.frame.origin.y==-160) {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                [UIView setAnimationDelegate:self];
                //position off screen
                self.view.frame=CGRectMake(0, 0, 320, 568);
                [UIView commitAnimations];
                [textMyWithdrawal resignFirstResponder];
            }
            
            if ([arrWithrawalOptions count]>3) {
                
                for (int i=0; i<countsubRecords; i++) {
                    
                    [arrWithrawalOptions removeLastObject];
                    
                }
                
            }
            
            isWithdrawalSelected=NO;
            
            SelectedOption=@"None";
            
            
            NSLog(@"%@",arrWithrawalOptions);
            [dictSelectedWithdrawal removeAllObjects];
            [self.menu reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            //[self.menu reloadData];
            [spinner startAnimating];
            [spinner setHidden:NO];
            
            serve*serveOBJ=[serve new];
            [serveOBJ setDelegate:self];
            serveOBJ.tagName=@"AutoWithdrawalCancel";
            [serveOBJ SaveFrequency:@"" type:@"" frequency:0];
            
            
            
            // Execute any code when the switch is OFF
            
            NSLog(@"Switch is OFF");
            
        }
        
    }
    
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString*strTitle=[actionSheet buttonTitleAtIndex:buttonIndex];
    if (![strTitle isEqualToString:@"Cancel"]) {
        if (!dictSelectedWithdrawal) {
            
            
            
            dictSelectedWithdrawal=[[NSMutableDictionary alloc]init];
            
        }
        
        isWithdrawalSelected=YES;
        [dictSelectedWithdrawal removeAllObjects];
        [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%@",[[arrAutoWithdrawalF objectAtIndex:buttonIndex] valueForKey:@"Name"]]forKey:[NSString stringWithFormat:@"%d",buttonIndex]];
        strTimeFrequency=[[arrAutoWithdrawalF objectAtIndex:buttonIndex] valueForKey:@"Days"];
        if ([strTimeFrequency isKindOfClass:[NSNull class]])
        {
            strTimeFrequency=@"(Last day @ 5PM)";
        }
        
        else if ([strTimeFrequency isEqualToString:@"1,2,3,4,5"]) {
            strTimeFrequency=@"(Mon-Fri @ 5PM)";
        }
        else if ([strTimeFrequency isEqualToString:@"5"]) {
            strTimeFrequency=@"(Fri @ 5PM)";
        }
        
        //  strTimeFrequency=[[arrAutoWithdrawalF objectAtIndex:buttonIndex] valueForKey:@"Days"];
        [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%d",buttonIndex] forKey:SelectedOption];
        
        
        countsubRecords=0;
        NSLog(@"%@",dictSelectedWithdrawal);
        countsubRecords++;
        [arrWithrawalOptions addObject:[[arrAutoWithdrawalF objectAtIndex:buttonIndex] valueForKey:@"Name"]];
#pragma mark- update service 21
        [spinner startAnimating];
        [spinner setHidden:NO];
        
        serve*serveOBJ=[serve new];
        
        serveOBJ.tagName=@"SaveWithdrawal";
        
        serveOBJ.Delegate=self;
        
        [serveOBJ SaveFrequency:[[arrAutoWithdrawalF objectAtIndex:buttonIndex] valueForKey:@"Id"] type:@"Frequency" frequency:0];
        
        [self.menu reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    else{
        [on_off setOn:NO];
    }
}
// Called when a button is clicked. The view will be automatically dismissed after this call returns

-(void)checkButtonCLicked:(UIButton*)sender

{
    
    if ([SelectedOption isEqualToString:@"Triggers"]) {
        
        if (!dictSelectedWithdrawal) {
            
            dictSelectedWithdrawal=[[NSMutableDictionary alloc]init];
            
        }
        
        isWithdrawalSelected=YES;
        
        [dictSelectedWithdrawal removeAllObjects];
        
        [dictSelectedWithdrawal setValue:[arrWithrawalOptions objectAtIndex:[sender tag]] forKey:[NSString stringWithFormat:@"%d",[sender tag]]];
        
        [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%d",[sender tag]] forKey:SelectedOption];
        
        NSLog(@"%@",arrAutoWithdrawalT);
        
        int tag=[sender tag];
        
        float value= [[[[arrAutoWithdrawalT objectAtIndex:tag-3] valueForKey:@"Name"] substringFromIndex:1] floatValue];
        [spinner startAnimating];
        [spinner setHidden:NO];
        
        serve*serveOBJ=[serve new];
        
        serveOBJ.tagName=@"SaveWithdrawal";
        
        serveOBJ.Delegate=self;
        
        [serveOBJ SaveFrequency:[[arrAutoWithdrawalT objectAtIndex:tag-3] valueForKey:@"Id"] type:SelectedOption frequency:value];
        
    }
    
    [self.menu reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}
#pragma mark-textfield delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}// return NO to disallow editing.
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([SelectedOption isEqualToString:@"Triggers"]) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        //position off screen
        self.view.frame=CGRectMake(0, -160, 320, 480);
        [UIView commitAnimations];
    }
    
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
