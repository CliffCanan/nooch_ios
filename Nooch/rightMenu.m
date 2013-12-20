//
//  rightMenu.m
//  Nooch
//
//  Created by Preston Hults on 5/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "rightMenu.h"

@interface rightMenu ()<UITextFieldDelegate,UIActionSheetDelegate>

@end
NSArray *bytedata;
NSString* selectedId;
bool isBank;
int verifyAttempts;

@implementation rightMenu

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    arrWithrawalOptions=[[NSMutableArray alloc]init];
    
    isWithdrawalSelected=NO;
    
    [arrWithrawalOptions addObject:@"NOOCH BALANCE"];
    
    [arrWithrawalOptions addObject:@"Add Funds"];
    
    [arrWithrawalOptions addObject:@"Withdraw Funds"];
    [arrWithrawalOptions addObject:@"Auto Cash Out"];
   
	// Do any additional setup after loading the view.
    menuTable.scrollEnabled = YES;
    storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    verifyAttempts = 0;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    if (self.view.frame.origin.y==-100) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        //position off screen
        self.view.frame=CGRectMake(0, 0, 320, 568);
        [UIView commitAnimations];
    }
    if ([SelectedOption isEqualToString:@"Triggers"]&&[Switch isOn]) {
        
        
        
        if ([dictSelectedWithdrawal count]==0) {
            
            SelectedOption=@"None";
            
            
            
        }
        
        if ([arrWithrawalOptions count]>4) {
            
            for (int i=0; i<countsubRecords; i++) {
                
                [arrWithrawalOptions removeLastObject];
                
            }
            
            
            
            [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
        
    }
    

}
-(void)viewDidAppear:(BOOL)animated{
    //isEditing=NO;
    [menuTable reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    isEditing=NO;
    serve*serveOBJ=[serve new];
    
    serveOBJ.tagName=@"withdrawOptions";
    
    [serveOBJ GetAllWithdrawalFrequency];
    
    serveOBJ.Delegate=self;
    
    
    [addBank.titleLabel setFont:[core nFont:@"Medium" size:18]]; [addCard.titleLabel setFont:[core nFont:@"Medium" size:18]]; [cancelSourceAdd.titleLabel setFont:[core nFont:@"Medium" size:18]];
    [addBank.layer setBorderWidth:1.0f]; [addBank.layer setBorderColor:[core hexColor:@"505761"].CGColor]; [addBank.layer setCornerRadius:10.0f]; [addBank setClipsToBounds:YES];
    [addCard.layer setBorderWidth:1.0f]; [addCard.layer setBorderColor:[core hexColor:@"505761"].CGColor]; [addCard.layer setCornerRadius:10.0f]; [addCard setClipsToBounds:YES];
    [cancelSourceAdd.layer setBorderWidth:1.0f]; [cancelSourceAdd.layer setBorderColor:[core hexColor:@"505761"].CGColor]; [cancelSourceAdd.layer setCornerRadius:10.0f]; [cancelSourceAdd setClipsToBounds:YES];
    [addSourceMenu setBackgroundColor:[core hexColor:@"3fabe1"]];
    [cancelSourceAdd setTitleColor:[core hexColor:@"FFFFFF"] forState:UIControlStateNormal];
    [addBank setTitleColor:[core hexColor:@"242e33"] forState:UIControlStateNormal];
    [addCard setTitleColor:[core hexColor:@"242e33"] forState:UIControlStateNormal];
    [menuTable reloadData];

    [removeSource.titleLabel setFont:[core nFont:@"Medium" size:18]]; [hideDetails.titleLabel setFont:[core nFont:@"Medium" size:18]]; [makePrimary.titleLabel setFont:[core nFont:@"Medium" size:18]];
    [updateExpire.titleLabel setFont:[core nFont:@"Medium" size:18]]; [detailsDescriptor setFont:[core nFont:@"Medium" size:18]]; [detailsTitle setFont:[core nFont:@"Bold" size:24]];
    [detailsTitle setTextColor:[core hexColor:@"242e33"]];
    [detailsDescriptor setTextColor:[core hexColor:@"242e33"]];
    [hideDetails setTitleColor:[core hexColor:@"FFFFFF"] forState:UIControlStateNormal];
    [removeSource setTitleColor:[core hexColor:@"242e33"] forState:UIControlStateNormal];
    [hideDetails setTitleColor:[core hexColor:@"242e33"] forState:UIControlStateNormal];
    [makePrimary setTitleColor:[core hexColor:@"242e33"] forState:UIControlStateNormal];
    [updateExpire setTitleColor:[core hexColor:@"242e33"] forState:UIControlStateNormal];

    [makePrimary setTitle:@"Make Primary" forState:UIControlStateNormal];
    [updateExpire setTitle:@"Update Expiration" forState:UIControlStateNormal];
    [hideDetails setTitle:@"Close" forState:UIControlStateNormal];
    [hideDetails addTarget:self action:@selector(hideDetailsView) forControlEvents:UIControlEventTouchUpInside];
    [makePrimary addTarget:self action:@selector(primary) forControlEvents:UIControlEventTouchUpInside];
    [updateExpire addTarget:self action:@selector(updateExpiration) forControlEvents:UIControlEventTouchUpInside];
    [removeSource addTarget:self action:@selector(del) forControlEvents:UIControlEventTouchUpInside];
    [me getBanks];
    [me getCards];
    [navCtrl.view endEditing:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake (10,0,200,30)];
    [title setFont:[core nFont:@"Medium" size:14.0]];
    title.textColor = [core hexColor:@"FFFFFF"];
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
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 29, 320, 1)];
    [bottomLine setBackgroundColor:[UIColor blackColor]];
    [headerView addSubview:bottomLine];
    [headerView addSubview:title];
    [headerView setBackgroundColor:[core hexColor:@"A1A1A1"]];
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
    if (section == 0) {
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];
    cell.userInteractionEnabled = YES;
    cell.indentationLevel = 1;
    cell.indentationWidth = 60;
    cell.textLabel.font = [core nFont:@"Regular" size:18.0];
    cell.textLabel.textColor = [core hexColor:@"FFFFFF"];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(24, 4, 32, 32)];
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(240, 13, 12, 18)];
    arrow.image = [UIImage imageNamed:@"Arrow.png"];
    
    if (indexPath.section == 0) {
        cell.textLabel.font = [core nFont:@"Medium" size:18.0];
        if (indexPath.row == 0) {
            cell.userInteractionEnabled = NO;
            cell.textLabel.text = [arrWithrawalOptions objectAtIndex:indexPath.row];
            cell.textLabel.font=[UIFont systemFontOfSize:15];
            iv.image = [UIImage imageNamed:@"n_Icon.png"];
            UILabel *balance = [[UILabel alloc] initWithFrame:CGRectMake(213, 12, 100, 20)];
            balance.backgroundColor = [UIColor clearColor];
            balance.textColor = [UIColor whiteColor];
            balance.text = [NSString stringWithFormat:@"$%@",[[me usr] objectForKey:@"Balance"]];
            balance.font = [core nFont:@"Bold" size:15];
            [cell.contentView addSubview:balance];
              cell.detailTextLabel.text=@"";
        }else if(indexPath.row == 1){
            [cell.contentView addSubview:arrow];
          ;
            if ([[[me usr] objectForKey:@"banks"] count]==0) {
                cell.userInteractionEnabled = NO;
                cell.textLabel.enabled = NO;
                cell.detailTextLabel.enabled = NO;
                cell.selectionStyle=UITableViewCellEditingStyleNone;
            }
            else
            {
                cell.userInteractionEnabled = YES;
                cell.textLabel.enabled = YES;
                cell.detailTextLabel.enabled = YES;
                //cell.selectionStyle=UITableViewCellEditingStyleNone;
            }
            cell.textLabel.text = [arrWithrawalOptions objectAtIndex:indexPath.row];
            iv.image = [UIImage imageNamed:@"AddFunds.png"];
              cell.detailTextLabel.text=@"";
        }else if(indexPath.row == 2){
            [cell.contentView addSubview:arrow];
            cell.textLabel.text = [arrWithrawalOptions objectAtIndex:indexPath.row];
            iv.image = [UIImage imageNamed:@"WithdrawFunds.png"];
            if ([[[me usr] objectForKey:@"banks"] count]==0) {
                cell.userInteractionEnabled = NO;
                cell.textLabel.enabled = NO;
                cell.detailTextLabel.enabled = NO;
                cell.selectionStyle=UITableViewCellEditingStyleNone;
            }
            else
            {
                cell.userInteractionEnabled = YES;
                cell.textLabel.enabled = YES;
                cell.detailTextLabel.enabled = YES;
                //cell.selectionStyle=UITableViewCellEditingStyleNone;
            }
              cell.detailTextLabel.text=@"";
        }
        else if (indexPath.row==3)
            
        {
            NSLog(@"%@",arrWithrawalOptions);
            cell.textLabel.text = [arrWithrawalOptions objectAtIndex:indexPath.row];
            
            cell.detailTextLabel.textColor=[UIColor whiteColor];
            
            Switch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 5, 70, 30)];
            
            Switch.tag=12000;
            
            
            
            if ([SelectedOption isEqualToString:@"Triggers"])
                
            {
                [Switch setOn:YES];
                
                if (dictSelectedWithdrawal) {
                    if ([dictSelectedWithdrawal valueForKey:SelectedOption]) {
                        NSString*option=[dictSelectedWithdrawal valueForKey:SelectedOption];
                        
                        // NSArray*arrSeparate=[[dictSelectedWithdrawal valueForKey:option] componentsSeparatedByString:@" "];
                        
                        
                        cell.detailTextLabel.textColor=[UIColor whiteColor];
                        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",[dictSelectedWithdrawal valueForKey:option]];
                        
                        SelectedSubOption=[dictSelectedWithdrawal valueForKey:option];
                    }
                    
                }
                
                else
                {
                    cell.detailTextLabel.text=@"";
                    
                }}
            else if([SelectedOption isEqualToString:@"Frequency"]){
                if ([dictSelectedWithdrawal valueForKey:SelectedOption]) {
                    [Switch setOn:YES];
                }
                
                
                cell.detailTextLabel.text=@"";
                
            }
            else
            {
                [Switch setOn:NO];
                
                cell.detailTextLabel.text=@"";
            }
            
            [Switch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
            
            [cell.contentView addSubview:Switch];
          
        }
        
        else{
           
            cell.textLabel.font = [core nFont:@"Medium" size:15.0];
            
            
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
                    [edit setFrame:CGRectMake(215, 5, 60, 30)];
                    
                    
                    
                    [edit addTarget:self action:@selector(editFrequency:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [cell.contentView addSubview:edit];
                    //[menuTable setEditing:!menuTable.editing animated:YES];
                }
                else
                {
                    UIButton*removeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
                    
                    [removeBtn  setTag:indexPath.row];
                    [removeBtn setTintColor:[UIColor whiteColor]];
                    [removeBtn setBackgroundColor:[UIColor redColor]];
                    [removeBtn setTitle:@"Remove" forState:UIControlStateNormal];
                    [removeBtn setFrame:CGRectMake(320, 5, 100, 35)];
                
                    [removeBtn addTarget:self action:@selector(RemoveFrequency:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [cell.contentView addSubview:removeBtn];

                    [UIView beginAnimations:nil context:nil];
                    
                    [UIView setAnimationDelegate:self];
                    [UIView setAnimationDuration:0.3];
                    subV.frame=CGRectMake(20, 5, 80, 35);
                    img.frame=CGRectMake(-40, 5, 40, 40);
                    [removeBtn setFrame:CGRectMake(180, 2, 90, 35)];
                   
                    [UIView commitAnimations];
                    
                
                                    }
                
            }
        else{
                
                cell.textLabel.text=[arrWithrawalOptions objectAtIndex:indexPath.row] ;
            if (indexPath.row==8) {
                
                
                textMyWithdrawal=[[UITextField alloc]initWithFrame:CGRectMake(90, 5, 70, 30)];
                
                
                
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
               
                [Savebtn setFrame:CGRectMake(165, 2, 100, 35)];
                
                
                
                
                
                
                //Savebtn.enabled=NO;
                //Savebtn.userInteractionEnabled=NO;
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
                
                [check setFrame:CGRectMake(210, 2, 50, 40)];
                
                [check addTarget:self action:@selector(checkButtonCLicked:) forControlEvents:UIControlEventTouchUpInside];
                
                [cell.contentView addSubview:check];

            }
            
            }
            
            cell.detailTextLabel.text=@"";
            
                    }
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            //BankName BankPicture
            if ([[[me usr] objectForKey:@"banks"] count] > 0) {
                [cell.contentView addSubview:arrow];
                NSLog(@"%@",[[[me usr] objectForKey:@"banks"] objectAtIndex:0]);
                NSLog(@"all bank %@",[[me usr] objectForKey:@"banks"] );
                NSDictionary *bank = [[[me usr] objectForKey:@"banks"] objectAtIndex:0];
                NSLog(@"bankkk%@",[bank objectForKey:@"BankAcctNumber"]);
                
                
                //bank verified or Not
                NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
                if ([[[me usr] objectForKey:@"banks"] objectAtIndex:0]&&[[[[[me usr] objectForKey:@"banks"] objectAtIndex:0] valueForKey:@"IsVerified"] intValue]==1 ) {
                    [defaults setValue:@"1" forKey:@"BankVerified"];
                    [defaults synchronize];
                    
                }
                //[state substringFromIndex: [state length] - 2];
                NSString*lastdigit=[NSString stringWithFormat:@"XXXX%@",[[bank objectForKey:@"BankAcctNumber"] substringFromIndex:[[bank objectForKey:@"BankAcctNumber"] length]-4]];
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[bank objectForKey:@"BankName"],lastdigit];
                cell.textLabel.font=[UIFont fontWithName:@"Arial" size:12.0f];
                bytedata = [bank valueForKey:@"BankPicture"];
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
                
        iv.image = [UIImage imageWithData:datos];
            }else{
                cell.userInteractionEnabled = NO;
                cell.textLabel.textColor = [core hexColor:@"adb1b3"];
                cell.textLabel.text = @"No Bank Accounts";
                iv.image = [UIImage imageNamed:@"Bank_Icon.png"];
            }
              cell.detailTextLabel.text=@"";
        }else if(indexPath.row == 1){
            if ([[[me usr] objectForKey:@"banks"] count] == 2) {
                [cell.contentView addSubview:arrow];
                NSDictionary *bank = [[[me usr] objectForKey:@"banks"] objectAtIndex:1];
                cell.textLabel.text = [NSString stringWithFormat:@"Account **** %@",[[bank objectForKey:@"BankAcctNumber"] substringFromIndex:[[bank objectForKey:@"BankAcctNumber"] length] -4]];
                iv.image = [UIImage imageNamed:@"Bank_Icon.png"];
            }else if([[[me usr] objectForKey:@"cards"] count] > 0) {
                [cell.contentView addSubview:arrow];
                NSDictionary *card = [[[me usr] objectForKey:@"cards"] objectAtIndex:0];
                cell.textLabel.text = [NSString stringWithFormat:@"Card **** %@",[[card objectForKey:@"CardNumber"] substringFromIndex:[[card objectForKey:@"CardNumber"] length] -4]];
                iv.image = [UIImage imageNamed:@"CreditCard_Icon.png"];
            }else{
                cell.userInteractionEnabled = NO;
                cell.textLabel.textColor = [core hexColor:@"adb1b3"];
                cell.textLabel.text = @"No Credit Cards";
                iv.image = [UIImage imageNamed:@"CreditCard_Icon.png"];
            }
              cell.detailTextLabel.text=@"";
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
                cell.userInteractionEnabled = NO;
                cell.textLabel.textColor = [core hexColor:@"adb1b3"];
                cell.textLabel.text = @"No Credit Cards";
                iv.image = [UIImage imageNamed:@"CreditCard_Icon.png"];
            }else{
                cell.textLabel.text = @"";
                cell.userInteractionEnabled = NO;
            }
              cell.detailTextLabel.text=@"";
        }else if(indexPath.row == 3){
            if ([[[me usr] objectForKey:@"cards"] count] == 2 && [[[me usr] objectForKey:@"banks"] count] == 2){
                [cell.contentView addSubview:arrow];
                NSDictionary *card = [[[me usr] objectForKey:@"cards"] objectAtIndex:1];
                cell.textLabel.text = [NSString stringWithFormat:@"Card **** %@",[[card objectForKey:@"CardNumber"] substringFromIndex:[[card objectForKey:@"CardNumber"] length] -4]];
                iv.image = [UIImage imageNamed:@"CreditCard_Icon.png"];
            }else{
                cell.textLabel.text = @"";
                cell.userInteractionEnabled = NO;
            }
        }
          cell.detailTextLabel.text=@"";
    }
    [cell.contentView addSubview:iv];
    cell.backgroundColor=[UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.view.frame.origin.y==-100) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        //position off screen
        self.view.frame=CGRectMake(0, 0, 320, 568);
        [UIView commitAnimations];
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            //[self hideActionMenu];
            if ([[[me usr] objectForKey:@"banks"] count] == 0) {
               
                UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"Attach an Account" message:@"Before you can add funds you must attach a bank account." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Go Now", nil];
                [set setTag:1];
                [set show];
                return;
                
            }
            
            [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"addFunds"] animated:YES completion:nil];
//            [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"addFunds"] animated:YES];
        }else if(indexPath.row == 2){
            //[self hideActionMenu];
            if ([[[me usr] objectForKey:@"banks"] count] == 0) {
                UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"Attach an Account" message:@"Before you can withdraw funds you must attach a bank account." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Go Now", nil];
                [set setTag:1];
                [set show];
                return;
            }
            [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"withdrawFunds"] animated:YES completion:nil];
           // [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"withdrawFunds"] animated:YES];
        }
        else if(indexPath.row==3)
            
        {
            
            if ([Switch isOn]&& [SelectedOption isEqualToString:@"Triggers"]) {
                
                if (isWithdrawalSelected) {
                    
                    isWithdrawalSelected=NO;
                    
                    if ([arrWithrawalOptions count]>4) {
                        
                        for (int i=0; i<countsubRecords; i++) {
                            
                            [arrWithrawalOptions removeLastObject];
                            
                        }
                        
                    }
                    
                    if (![dictSelectedWithdrawal valueForKey:SelectedOption]) {
                        
                        SelectedOption=@"None";
                        
                    }
                    
                    //SelectedOption
                    
                }
                
                else if (!isWithdrawalSelected)
                    
                    
                    
                {
                    
                    isWithdrawalSelected=YES;
                    
                    temp = [dictSelectedWithdrawal allKeysForObject:SelectedSubOption];
                    
                    NSLog(@"%@",temp);
                    
                    // NSString *key = [temp objectAtIndex:0];
                    
                    temp2=[dictSelectedWithdrawal allKeysForObject:[temp objectAtIndex:0]];
                    
                    
                    
                    //SelectedSubOption
                    
//                    if ([[temp2 objectAtIndex:0]isEqualToString:@"Frequency"]) {
//                        
//                        countsubRecords=0;
//                        
////                        for (NSDictionary*dict in arrAutoWithdrawalF) {
////                            
////                            countsubRecords++;
////                            
////                            [arrWithrawalOptions addObject:[NSString stringWithFormat:@"%@ at %@",[dict valueForKey:@"Name"],[dict valueForKey:@"Time"]]];
////                            
////                        }
//                        [arrWithrawalOptions addObject:@"$"];
//                        countsubRecords++;
//                        
//                        
//                    }
                    
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
                
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                //  [menuTable reloadData];
                
            }
            
        }
        
//        else if(indexPath.row==8)
//            
//        {
//            
//            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"NoochMoney" message:@"Custom Withdrawal Between $10-$100" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//            
//            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
//            
//            
//            
//            [alert setTag:12002];
//            
//            [alert show];
//            
//        }
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            if ([[[me usr] objectForKey:@"banks"] count] > 0) {
                isBank = YES;
                NSDictionary *bank = [[[me usr] objectForKey:@"banks"] objectAtIndex:0];
                CGRect frame = CGRectMake(0, 600, 320, 500);
                [detailsPopup setFrame:frame];
                [verifyView setFrame:frame];
                [detailsTitle setText:@"Bank Account"];
                [detailsDescriptor setText:[NSString stringWithFormat:@"Account ending in %@",[[bank objectForKey:@"BankAcctNumber"] substringFromIndex:[[bank objectForKey:@"BankAcctNumber"] length] -4]]];
                shadow = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 600)];
                [shadow setBackgroundColor:[UIColor blackColor]];
                [shadow setAlpha:0.0f];
                [shadow setUserInteractionEnabled:YES];
                [self.view.window addSubview:shadow];
                [self.view.window addSubview:detailsPopup];
                [self.view.window addSubview:verifyView];
                [updateExpire setHidden:YES];
                [removeSource setTitle:@"Delete Account" forState:UIControlStateNormal];
                
                if (![[bank objectForKey:@"IsVerified"] boolValue]) {
                    [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"verify"] animated:YES completion:nil];
                 //   [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"verify"] animated:YES];
                }else{
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:0.5];
                    frame.origin.y = 180;
                    CGRect delFrame = removeSource.frame;
                    CGRect cancelFrame = hideDetails.frame;
                    if ([[bank objectForKey:@"IsPrimary"] boolValue]) {
                        [makePrimary setHidden:YES];
                        delFrame.origin.y = 80;
                        cancelFrame.origin.y = 140;
                        frame.origin.y = [UIScreen mainScreen].bounds.size.height - 200;
                    }else{
                        delFrame.origin.y = 130;
                        cancelFrame.origin.y = 190;
                        frame.origin.y = [UIScreen mainScreen].bounds.size.height - 250;
                    }
                    [detailsPopup setFrame:frame];
                    [shadow setAlpha:0.5f];
                    [UIView commitAnimations];
                    [removeSource setFrame:delFrame];
                    [hideDetails setFrame:cancelFrame];
                }
                
                selectedId = [bank objectForKey:@"BankAccountId"];
                [[NSUserDefaults standardUserDefaults] setObject:selectedId forKey:@"choice"];
            }
        }else if(indexPath.row == 1){
            if ([[[me usr] objectForKey:@"banks"] count] == 2) {
                isBank = YES;
                NSDictionary *bank = [[[me usr] objectForKey:@"banks"] objectAtIndex:1];
                [detailsTitle setText:@"Bank Account"];
                [detailsDescriptor setText:[NSString stringWithFormat:@"Account ending in %@",[[bank objectForKey:@"BankAcctNumber"] substringFromIndex:[[bank objectForKey:@"BankAcctNumber"] length] -4]]];
                CGRect frame = CGRectMake(0, 600, 320, 500);
                [detailsPopup setFrame:frame];
                [verifyView setFrame:frame];
                shadow = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 600)];
                [shadow setBackgroundColor:[UIColor blackColor]];
                [shadow setAlpha:0.0f];
                [shadow setUserInteractionEnabled:YES];
                [self.view.window addSubview:shadow];
                [self.view.window addSubview:detailsPopup];
                [self.view.window addSubview:verifyView];
                [updateExpire setHidden:YES];
                [removeSource setTitle:@"Delete Account" forState:UIControlStateNormal];
                
                if (![[bank objectForKey:@"IsVerified"] boolValue]) {
                    [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"verify"] animated:YES completion:nil];
                  //  [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"verify"] animated:YES];
                }else{
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:0.5];
                    frame.origin.y = 180;
                    CGRect delFrame = removeSource.frame;
                    CGRect cancelFrame = hideDetails.frame;
                    if ([[bank objectForKey:@"IsPrimary"] boolValue]) {
                        [makePrimary setHidden:YES];
                        delFrame.origin.y = 80;
                        cancelFrame.origin.y = 140;
                        frame.origin.y = [UIScreen mainScreen].bounds.size.height - 200;
                    }else{
                        delFrame.origin.y = 130;
                        cancelFrame.origin.y = 190;
                        frame.origin.y = [UIScreen mainScreen].bounds.size.height - 250;
                    }
                    [detailsPopup setFrame:frame];
                    [shadow setAlpha:0.5f];
                    [UIView commitAnimations];
                    [removeSource setFrame:delFrame];
                    [hideDetails setFrame:cancelFrame];
                }
                
                selectedId = [bank objectForKey:@"BankAccountId"];
                [[NSUserDefaults standardUserDefaults] setObject:selectedId forKey:@"choice"];
            }else if([[[me usr] objectForKey:@"cards"] count] > 0) {
                isBank = NO;
                NSDictionary *card = [[[me usr] objectForKey:@"cards"] objectAtIndex:0];
                [detailsTitle setText:@"Debit/Credit Card"];
                
                [detailsDescriptor setText:[NSString stringWithFormat:@"Card ending in %@",[[card objectForKey:@"CardNumber"] substringFromIndex:[[card objectForKey:@"CardNumber"] length] -4]]];
                CGRect frame = CGRectMake(0, 480, 320, 500);
                [detailsPopup setFrame:frame];
                shadow = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 600)];
                [shadow setBackgroundColor:[UIColor blackColor]];
                [shadow setAlpha:0.0f];
                [shadow setUserInteractionEnabled:YES];
                [self.view.window addSubview:shadow];
                [self.view.window addSubview:detailsPopup];
                [updateExpire setHidden:NO];
                [removeSource setTitle:@"Delete Card" forState:UIControlStateNormal];
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                frame.origin.y = 180;
                [detailsPopup setFrame:frame];
                [shadow setAlpha:0.5f];
                [UIView commitAnimations];
                selectedId = [card objectForKey:@"CardId"];
                if ([[card objectForKey:@"IsPrimary"] boolValue]) {
                    [makePrimary setHidden:YES];
                }
            }
        }else if(indexPath.row == 2){
            if ([[[me usr] objectForKey:@"banks"] count] == 2 && [[[me usr] objectForKey:@"cards"] count] > 0) {
                isBank = NO;
                NSDictionary *card = [[[me usr] objectForKey:@"cards"] objectAtIndex:0];
                [detailsTitle setText:@"Debit/Credit Card"];
                [detailsDescriptor setText:[NSString stringWithFormat:@"Card ending in %@",[[card objectForKey:@"CardNumber"] substringFromIndex:[[card objectForKey:@"CardNumber"] length] -4]]];
                CGRect frame = CGRectMake(0, 480, 320, 500);
                [detailsPopup setFrame:frame];
                shadow = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 600)];
                [shadow setBackgroundColor:[UIColor blackColor]];
                [shadow setAlpha:0.0f];
                [shadow setUserInteractionEnabled:YES];
                [self.view.window addSubview:shadow];
                [self.view.window addSubview:detailsPopup];
                [updateExpire setHidden:NO];
                [removeSource setTitle:@"Delete Card" forState:UIControlStateNormal];
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                frame.origin.y = 180;
                [detailsPopup setFrame:frame];
                [shadow setAlpha:0.5f];
                [UIView commitAnimations];
                selectedId = [card objectForKey:@"CardId"];
                if ([[card objectForKey:@"IsPrimary"] boolValue]) {
                    [makePrimary setHidden:YES];
                }
            }else if([[[me usr] objectForKey:@"banks"] count] == 1 && [[[me usr] objectForKey:@"cards"] count] == 2){
                isBank = NO;
                NSDictionary *card = [[[me usr] objectForKey:@"cards"] objectAtIndex:1];
                [detailsTitle setText:@"Debit/Credit Card"];
                [detailsDescriptor setText:[NSString stringWithFormat:@"Card ending in %@",[[card objectForKey:@"CardNumber"] substringFromIndex:[[card objectForKey:@"CardNumber"] length] -4]]];
                CGRect frame = CGRectMake(0, 480, 320, 500);
                [detailsPopup setFrame:frame];
                shadow = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 600)];
                [shadow setBackgroundColor:[UIColor blackColor]];
                [shadow setAlpha:0.0f];
                [shadow setUserInteractionEnabled:YES];
                [self.view.window addSubview:shadow];
                [self.view.window addSubview:detailsPopup];
                [updateExpire setHidden:NO];
                [removeSource setTitle:@"Delete Card" forState:UIControlStateNormal];
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                frame.origin.y = 180;
                [detailsPopup setFrame:frame];
                [shadow setAlpha:0.5f];
                [UIView commitAnimations];
                selectedId = [card objectForKey:@"CardId"];
                if ([[card objectForKey:@"IsPrimary"] boolValue]) {
                    [makePrimary setHidden:YES];
                }
            }
        }else if(indexPath.row == 3){
            if ([[[me usr] objectForKey:@"cards"] count] == 2 && [[[me usr] objectForKey:@"banks"] count] == 2){
                isBank = NO;
                NSDictionary *card = [[[me usr] objectForKey:@"cards"] objectAtIndex:1];
                [detailsTitle setText:@"Debit/Credit Card"];
                [detailsDescriptor setText:[NSString stringWithFormat:@"Card ending in %@",[[card objectForKey:@"CardNumber"] substringFromIndex:[[card objectForKey:@"CardNumber"] length] -4]]];
                CGRect frame = CGRectMake(0, 480, 320, 500);
                [detailsPopup setFrame:frame];
                shadow = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 600)];
                [shadow setBackgroundColor:[UIColor blackColor]];
                [shadow setAlpha:0.0f];
                [shadow setUserInteractionEnabled:YES];
                [self.view.window addSubview:shadow];
                [self.view.window addSubview:detailsPopup];
                [updateExpire setHidden:NO];
                [removeSource setTitle:@"Delete Card" forState:UIControlStateNormal];
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                frame.origin.y = 180;
                [detailsPopup setFrame:frame];
                [shadow setAlpha:0.5f];
                [UIView commitAnimations];
                selectedId = [card objectForKey:@"CardId"];
                if ([[card objectForKey:@"IsPrimary"] boolValue]) {
                    [makePrimary setHidden:YES];
                }
            }
        }
    }
}
-(void)editFrequency:(id)sender{
    if (!isEditing) {
        isEditing=YES;
    }
    [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)RemoveFrequency:(id)sender{
    isEditing=NO;
     [Switch setOn:NO animated:YES];
    [arrWithrawalOptions removeLastObject];
    [dictSelectedWithdrawal removeAllObjects];
    serve*serveOBJ=[serve new];
    serveOBJ.tagName=@"AutoWithdrawalCancel";
    [serveOBJ SaveFrequency:@"" type:@"" frequency:0];
    [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];

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
    
    [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"$%@",textMyWithdrawal.text] forKey:[NSString stringWithFormat:@"%d",8]];
    
    [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%d",8] forKey:SelectedOption];
    //[dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%d",8] forKey:SelectedOption];
    
    
    NSLog(@"%@",dictSelectedWithdrawal);
    
    serve*serveOBJ=[serve new];
    
    serveOBJ.tagName=@"SaveWithdrawal";
    
    serveOBJ.Delegate=self;
    
    [serveOBJ SaveFrequency:@"" type:@"Tiggers" frequency:[textMyWithdrawal.text floatValue]];
    
    [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];

}
/*
-(void)openpickerMethod:(id)sender
{
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
   // tagSelectedRow=[sender tag];
    if (![self.view.subviews containsObject:myPickerView] && ![self.view.subviews containsObject:toolbar]) {
        toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 44);
   NSMutableArray *items = [[NSMutableArray alloc] init];
        [items addObject:[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:Nil]];
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]];
        [items addObject:[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(pickerDown)] ];
        [toolbar setItems:items animated:NO];
        [self.view addSubview:toolbar];

        myPickerView= [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height+44, 320, 200)];
        myPickerView.delegate = self;
        myPickerView.backgroundColor=[UIColor blackColor];
        myPickerView.showsSelectionIndicator = YES;
        
        [self.view addSubview:myPickerView];
    }
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [toolbar setFrame:CGRectMake(0, self.view.frame.size.height-220, 320, 44)];
    myPickerView.frame=CGRectMake(0, self.view.frame.size.height-180, 320, 200);
    [UIView commitAnimations];
  
}
-(void)pickerDown
{
    if (!dictSelectedWithdrawal) {
        
        
        
        dictSelectedWithdrawal=[[NSMutableDictionary alloc]init];
        
        
        
    }
    
    
    
    isWithdrawalSelected=YES;
    
    
    
    [dictSelectedWithdrawal removeAllObjects];
    
    
    
    [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%@ %@",[[arrAutoWithdrawalF objectAtIndex:tagSelectedRow] valueForKey:@"Name"],textMyWithdrawal.text]forKey:[NSString stringWithFormat:@"%d",tagSelectedRow]];
    
    
    
    [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%d",tagSelectedRow] forKey:SelectedOption];
    
    
    
    NSLog(@"%@",dictSelectedWithdrawal);
    
    serve*serveOBJ=[serve new];
    
    serveOBJ.tagName=@"SaveWithdrawal";
    
    serveOBJ.Delegate=self;
    
    [serveOBJ SaveFrequency:[[arrAutoWithdrawalF objectAtIndex:tagSelectedRow] valueForKey:@"Id"] type:@"Frequency" frequency:[textMyWithdrawal.text floatValue]];
    
    [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [toolbar setFrame:CGRectMake(0, self.view.frame.size.height, 320, 44)];
    myPickerView.frame=CGRectMake(0, self.view.frame.size.height+44, 320, 200);
    [UIView commitAnimations];
   // [menuTable reloadSections:<#(NSIndexSet *)#> withRowAnimation:<#(UITableViewRowAnimation)#>
        [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}
 */
- (void)changeSwitch:(id)sender{
    
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
   
    if (![[defaults valueForKey:@"BankVerified"]isEqualToString:@"1"]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Verify Your Bank Account To Enable Auto Cash Out" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil] ;
        [alert show];
        [Switch setOn:NO];
        return;
    }
    if (![[defaults valueForKey:@"ProfileComplete"]isEqualToString:@"YES"]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Complete Your Profile To Enable Auto Cash Out" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil] ;
        [alert show];
         [Switch setOn:NO];
        return;
    }
    
    if ([sender tag]==12000) {
        
        if([sender isOn]){
            
            isWithdrawalSelected=YES;
            NSLog(@"%@",arrWithrawalOptions);
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Withdrawal Options" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Frequency",@"Triggers", nil];
            
            [alert setTag:12003];
            
            
            
            [alert show];
            
            // Execute any code when the switch is ON
            
            NSLog(@"Switch is ON");
            
        }
        
        else{
            if (self.view.frame.origin.y==-100) {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                [UIView setAnimationDelegate:self];
                //position off screen
                self.view.frame=CGRectMake(0, 0, 320, 568);
                [UIView commitAnimations];
            }
            
            if ([arrWithrawalOptions count]>4) {
                
                for (int i=0; i<countsubRecords; i++) {
                    
                    [arrWithrawalOptions removeLastObject];
                    
                }
                
            }
            
            isWithdrawalSelected=NO;
            
            SelectedOption=@"None";
            
            
            NSLog(@"%@",arrWithrawalOptions);
            [dictSelectedWithdrawal removeAllObjects];
            [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            serve*serveOBJ=[serve new];
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
       serve*serveOBJ=[serve new];
        
        serveOBJ.tagName=@"SaveWithdrawal";
        
        serveOBJ.Delegate=self;
        
        [serveOBJ SaveFrequency:[[arrAutoWithdrawalF objectAtIndex:buttonIndex] valueForKey:@"Id"] type:@"Frequency" frequency:0];
       
        [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];

    }
    else{
        [Switch setOn:NO];
    }
}
// Called when a button is clicked. The view will be automatically dismissed after this call returns

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex

{
    if (alertView.tag == 16 && buttonIndex == 1) {
        profileGO = YES;
        [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"settings"] animated:YES completion:nil];
        // [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"settings"] animated:YES];
    }else if(alertView.tag == 1 && buttonIndex == 1){
        [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"addBank"] animated:YES completion:nil];
        
    }
    
    else if ([alertView tag]==12003) {
        
        if (buttonIndex==0) {
            
            SelectedOption=@"None";
            
            [Switch setOn:NO animated:YES];
            
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
            
            if ([arrWithrawalOptions count]>4) {
                
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
            
            [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            
            
            
            
            [alertView dismissWithClickedButtonIndex:2 animated:YES];
            
            NSLog(@"Trigger");
            
            
            
        }
        
    }
    
    else if ([alertView tag]==12002)
        
    {
        
        if (buttonIndex==1) {
            
            UITextField *value = [alertView textFieldAtIndex:0];
            
            if ([value.text floatValue]<10 ||[value.text floatValue]>100 ) {
                
                value.text=@"";
                
                
                
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"NoochMoney" message:@"Custom Withdrawal Between $10-$100" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                
                [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                
                
                
                [alert setTag:12002];
                
                [alert show];
                
            }
            
            else
                
            {
                
                if (!dictSelectedWithdrawal) {
                    
                    dictSelectedWithdrawal=[[NSMutableDictionary alloc]init];
                    
                }
                
                isWithdrawalSelected=YES;
                
                [dictSelectedWithdrawal removeAllObjects];
                
                [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"$%@",value.text] forKey:[NSString stringWithFormat:@"%d",8]];
                
                [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%d",8] forKey:SelectedOption];
                
                NSLog(@"%@",dictSelectedWithdrawal);
                
                serve*serveOBJ=[serve new];
                
                serveOBJ.tagName=@"SaveWithdrawal";
                
                serveOBJ.Delegate=self;
                
                [serveOBJ SaveFrequency:@"0" type:@"Tiggers" frequency:[value.text floatValue]];
                
                [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                
                
            }
            
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
                
                NSLog(@"%@",value.text);
                
                if (!dictSelectedWithdrawal) {
                    
                    
                    
                    dictSelectedWithdrawal=[[NSMutableDictionary alloc]init];
                    
                    
                    
                }
                
                
                
                isWithdrawalSelected=YES;
                
                
                
                [dictSelectedWithdrawal removeAllObjects];
                
                
                
                [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%@ %@",[arrWithrawalOptions objectAtIndex:tagForFrequency],value.text]  forKey:[NSString stringWithFormat:@"%d",tagForFrequency]];
                
                
                
                [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%d",tagForFrequency] forKey:SelectedOption];
                
                
                
                NSLog(@"%@",dictSelectedWithdrawal);
                
                serve*serveOBJ=[serve new];
                
                serveOBJ.tagName=@"SaveWithdrawal";
                
                serveOBJ.Delegate=self;
                
                [serveOBJ SaveFrequency:[[arrAutoWithdrawalF objectAtIndex:tagForFrequency-4] valueForKey:@"Id"] type:@"Frequency" frequency:[value.text floatValue]];
                
                [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                
            }
            
        }
        
    }
    
}
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
        
        NSLog(@"%@",dictSelectedWithdrawal);
        
        int tag=[sender tag];
        
        float value= [[[[arrAutoWithdrawalT objectAtIndex:tag-4] valueForKey:@"Name"] substringFromIndex:1] floatValue];
        serve*serveOBJ=[serve new];
        
        serveOBJ.tagName=@"SaveWithdrawal";
        
        serveOBJ.Delegate=self;

        [serveOBJ SaveFrequency:[[arrAutoWithdrawalT objectAtIndex:tag-4] valueForKey:@"Id"] type:SelectedOption frequency:value];
        
    }
    
//    else
//        
//    {
//        
//        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"NoochMoney" message:@"Custom Withdrawal Between $10-$100" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//        
//        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
//        
//        tagForFrequency=[sender tag];
//        
//        [alert setTag:12045];
//        
//        [alert show];
//        
//    }
    
    
    
    [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}
/*
#pragma mark- picker Delegates
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    tagSelectedRow=row;
   }

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [arrAutoWithdrawalF count];
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 50)];
    label.backgroundColor = [UIColor grayColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment=NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Arial" size:18];
    NSString *title;
    title = [NSString stringWithFormat:@"%@",[[arrAutoWithdrawalF objectAtIndex:row] valueForKey:@"Name"]];
    
    label.text = title;
    return label;
}
// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 320;
    
    return sectionWidth;
}
*/
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
        self.view.frame=CGRectMake(0, -100, 320, 480);
        [UIView commitAnimations];
    }
    
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
     /*if ([[NSString stringWithFormat:@"%@%@",textField.text,string] intValue]>10 && [[NSString stringWithFormat:@"%@%@",textField.text,string] intValue]<100)
    {
         Savebtn.userInteractionEnabled=YES;
        Savebtn.enabled=YES;
        [Savebtn setBackgroundColor:[UIColor greenColor]];
    }
    if ([[NSString stringWithFormat:@"%@%@",textField.text,string] intValue]<10 || [[NSString stringWithFormat:@"%@%@",textField.text,string] intValue]>100)
    {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"NoochMoney" message:@"Please Enter Amount Between $10-$100" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        Savebtn.userInteractionEnabled=NO;
        Savebtn.enabled=NO;
        [Savebtn setBackgroundColor:[UIColor grayColor]];
    }*/
    return YES;
}// return NO to not change text

              // called when clear button pressed. return NO to ignore (no notifications)
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void)primaryBankPopup{
    
}

-(void)hideDetailsView{
    CGRect frame = detailsPopup.frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    frame.origin.y = 600;
    [detailsPopup setFrame:frame];
    [shadow setAlpha:0.0f];
    [UIView commitAnimations];
}
- (IBAction)cancelBankVerification:(id)sender {
    [verifyAmount1 resignFirstResponder];
    [verifyAmount2 resignFirstResponder];
    CGRect frame = verifyView.frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    frame.origin.y = 600;
    [shadow setAlpha:0.0f];
    [verifyView setFrame:frame];
    [UIView commitAnimations];
}
- (IBAction)submitBankVerification:(id)sender {
    [verifyAmount1 resignFirstResponder];
    [verifyAmount2 resignFirstResponder];
    NSString *amountOne=verifyAmount1.text;
    NSString *amountTwo=verifyAmount2.text;
    if((([amountOne intValue] < 100) && ([amountOne intValue] > 0)) && (([amountTwo intValue] < 100) && ([amountTwo intValue] > 0)))
    {
        verifyAttempts++;
        serve *ver  = [serve new];
        ver.tagName = @"verification";
        ver.Delegate = self;
        [ver verifyBank:selectedId microOne:amountOne microTwo:amountTwo];
        [me waitStat:@"Attempting to verify your account..."];
    }
    else
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"Please enter valid amounts." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alertView sizeToFit];
        [alertView show];
        verifyAmount1.text=@"";
        verifyAmount2.text=@"";
    }
}

-(void)primary{
    NSLog(@"huhhh");
    [self.view.window addSubview:[me waitStat:@"Processing your request..."]];
    if (isBank) {
        serve *bankPrimary = [serve new];
        bankPrimary.tagName = @"bPrimary";
        bankPrimary.Delegate = self;
        [bankPrimary makeBankPrimary:selectedId];
    }else{
        serve *card = [serve new];
        card.tagName = @"cPrimary";
        card.Delegate = self;
        [card makeCardPrimary:selectedId];
    }
}

-(void)del{
    NSLog(@"huhhh");
    [self.view.window addSubview:[me waitStat:@"Processing your request..."]];
    if (isBank) {
        serve *bank = [serve new];
        bank.tagName = @"bDelete";
        bank.Delegate = self;
        [bank deleteBank:selectedId];
    }else{
        serve *card = [serve new];
        card.tagName = @"cDelete";
        card.Delegate = self;
        [card deleteCard:selectedId];
    }
}

-(void)updateExpiration{

}

- (IBAction)addSourceButton:(id)sender {
    if (self.view.frame.origin.y==-100) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        //position off screen
        self.view.frame=CGRectMake(0, 0, 320,568);
        [UIView commitAnimations];
    }
    if (![[me usr] objectForKey:@"validated"] || ![[[me usr] objectForKey:@"validated"] boolValue]) {
        UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"One Last Step..." message:@"Before you can attach a funding source we must verify who you are. Please help us keep Nooch safe and complete your profile." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Go Now", nil];
        [set setTag:16];
        [set show];
        return;
    }

    CGRect frame = CGRectMake(0, 480, 320, 300);
    [addSourceMenu setFrame:frame];
    shadow = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 600)];
    [shadow setBackgroundColor:[UIColor blackColor]];
    [shadow setAlpha:0.0f];
    [shadow setUserInteractionEnabled:YES];
    [self.view.window addSubview:shadow];
    [self.view.window addSubview:addSourceMenu];
    [addBank setTitle:@"Add a Bank Account" forState:UIControlStateNormal];
    [addBank addTarget:self action:@selector(attachBank) forControlEvents:UIControlEventTouchUpInside];
    [addCard setTitle:@"Add a Credit or Debit Card" forState:UIControlStateNormal];
    [addCard addTarget:self action:@selector(attachCard) forControlEvents:UIControlEventTouchUpInside];
    [cancelSourceAdd setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelSourceAdd addTarget:self action:@selector(hideActionMenu) forControlEvents:UIControlEventTouchUpInside];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    frame.origin.y = 280;
    if([[UIScreen mainScreen] bounds].size.height > 480){
        frame.origin.y = 370;
    }
    [addSourceMenu setFrame:frame];
    [shadow setAlpha:0.5f];
    [UIView commitAnimations];
}
-(void)attachBank{
    if ([[[me usr] objectForKey:@"banks"] count]==2) {
       [self hideActionMenu];
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"NoochMoney" message:@"You can't add more than  2 Bank Accounts " delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
    }
    else
    {
    [self hideActionMenu];
   // UIView*bankListView=[[UIView alloc]initWithFrame:CGRectMake(0, 50, 320, 420)];
    [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"addBank"] animated:YES completion:nil];
    }
   //     [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"addBank"] animated:YES];
}
-(void)attachCard{
    [self hideActionMenu];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Coming Soon" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    //[navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"addCard"] animated:YES];
}
-(void)hideActionMenu{
    [shadow removeFromSuperview];
    CGRect frame = addSourceMenu.frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    frame.origin.y = 600;
    [addSourceMenu setFrame:frame];
    [shadow setAlpha:0.0f];
    [UIView commitAnimations];
}



-(void)listen:(NSString *)result tagName:(NSString *)tagName{
    [me endWaitStat];
    NSLog(@"%@",arrWithrawalOptions);
    NSDictionary *loginResult = [result JSONValue];

    NSArray*arr=[result JSONValue];
    
    NSLog(@"%@",dictResult);
    if ([tagName isEqualToString:@"selectedWithdrawal"]) {
        NSLog(@"%@",arrAutoWithdrawalF);
        if ([loginResult valueForKey:@"Result"]) {
            NSArray*arr=[[loginResult valueForKey:@"Result"] componentsSeparatedByString:@","];
            NSLog(@"%@",arr);
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
                        NSLog(@"%@",dictSelectedWithdrawal);
                        countsubRecords++;
                        for (int i=4; i<[arrWithrawalOptions count]; i++) {
                            [arrWithrawalOptions removeObjectAtIndex:i];
                        }
                        
                        [arrWithrawalOptions addObject:[NSString stringWithFormat:@"%@",[dict valueForKey:@"Name"]]];
                        [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                       
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
                    [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];

                }
                else{
                for (int i=0;i<arrAutoWithdrawalT.count;i++) {
                    NSDictionary*dict=[arrAutoWithdrawalT objectAtIndex:i];
                    if ([[dict valueForKey:@"Id"] isEqualToString:[arr objectAtIndex:0]]) {
                SelectedOption=@"Triggers";
                        if (!dictSelectedWithdrawal) {
                            
                            dictSelectedWithdrawal=[[NSMutableDictionary alloc]init];
                            
                        }
                        //[dictSelectedWithdrawal setValue:[arrWithrawalOptions objectAtIndex:[sender tag]] forKey:[NSString stringWithFormat:@"%d",[sender tag]]];
                        
                       // [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%d",[sender tag]] forKey:SelectedOption];

                        //isWithdrawalSelected=YES;
                        
                        [dictSelectedWithdrawal removeAllObjects];
                        
                        [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"At $%@",[[arrAutoWithdrawalT objectAtIndex:[arrAutoWithdrawalT indexOfObject:dict]] valueForKey:@"AmountCredited"]] forKey:[NSString stringWithFormat:@"%d",[arrAutoWithdrawalT indexOfObject:dict]+4]];
                        
                        [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%d",[arrAutoWithdrawalT indexOfObject:dict]+4] forKey:SelectedOption];
                         [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                        NSLog(@"%@",dictSelectedWithdrawal);
                    
                    }
                }
                }
            }
        
    }
    }
   else if ([tagName isEqualToString:@"withdrawOptions"])
        
    {
        
        // NSLog(@"response %@",[dictResult valueForKey:@"Result"]);
        arrAutoWithdrawalF=[[NSMutableArray alloc]init];
        arrAutoWithdrawalF=[arr mutableCopy];
        
        NSLog(@"%@",arrAutoWithdrawalF);
        
        
        
        serve *serveOBJ=[serve new];
        
        serveOBJ.Delegate=self;
        
        serveOBJ.tagName=@"Triggers";
        
        [serveOBJ GetAllWithdrawalTrigger];
        
        
        
    }
    
    else if ([tagName isEqualToString:@"Triggers"])
        
    {
        arrAutoWithdrawalT=[[NSMutableArray alloc]init];
        arrAutoWithdrawalT=[arr mutableCopy];

        
        
        NSLog(@"%@",arrAutoWithdrawalT);
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"selectedWithdrawal";
        [serveOBJ getAutoWithDrawalSelectedOption];

        
        
        
        
    }
    
    else if ([tagName isEqualToString:@"SaveWithdrawal"])
        
    {
        
        dictResponse=[result JSONValue];
        
        NSLog(@"%@",[[dictResponse valueForKey:@"SaveFrequencyResult"] valueForKey:@"Result"]);
        
        if ([[[dictResponse valueForKey:@"SaveFrequencyResult"] valueForKey:@"Result"]isEqualToString:@"Saved Successfully"]) {
           
            NSLog(@"%@",@"Saved withdrawal");
//            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:[[dictResponse valueForKey:@"SaveFrequencyResult"] valueForKey:@"Result"] delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
//            
//            [alert show];
            
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
    else if ([tagName isEqualToString:@"bPrimary"]) {
        if([(NSString *)[loginResult valueForKey:@"Result"] isEqualToString:@"This account is marked as primary bank account successfully."])
        {
            [self hideDetailsView];
            [self.slidingViewController resetTopView];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"This account is now your primary bank account for Nooch." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }else if ([tagName isEqualToString:@"cPrimary"]) {
        if([(NSString *)[loginResult valueForKey:@"Result"] isEqualToString: @"This account is marked as primary card account successfully."]){
            [self hideDetailsView];
            [self.slidingViewController resetTopView];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"This card is now your primary card for Nooch." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView sizeToFit];
            [alertView show];
        }
        
    }else if ([tagName isEqualToString:@"bDelete"]) {
        if([(NSString *)[loginResult valueForKey:@"Result"] isEqualToString:@"Your bank account details has been deleted successfully."])
        {
            [self hideDetailsView];
            [self.slidingViewController resetTopView];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"The bank account details have been deleted." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView sizeToFit];
            [alertView show];
            [me getBanks];
            [menuTable reloadData];
        
        }
    }else if ([tagName isEqualToString:@"cDelete"]) {
        NSLog(@"Delete card return: %@", loginResult);
        if([(NSString *)[loginResult valueForKey:@"Result"] isEqualToString: @"Your card account details has been deleted successfully."]){
            [self hideDetailsView];
            [self.slidingViewController resetTopView];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"The card details have been deleted." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView sizeToFit];
            [alertView show];
        }
    }else if([tagName isEqualToString:@"verification"]){
        if([[loginResult objectForKey:@"Result"] isEqualToString:@"Your bank account is verified successfully."]){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Eureka!"message:@"Your bank account information all checks out, you’re free to go. Nooch forth."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView sizeToFit];
            [alertView show];
            [alertView setTag:4];
            verifyView.hidden = YES;
            verifyAttempts = 0;
        }else if(verifyAttempts == 2){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Careful..."message:@"You've failed verification twice now. We're getting suspicious, one more failed verification attempt and this bank account will be deleted from our system."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView sizeToFit];
            [alertView show];
        }else if(verifyAttempts == 3) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh oh!"message:@"You've failed verification three times now. Not that we don't trust you, but it's starting to look like the account doesn't belong to you."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView sizeToFit];
            [alertView show];
            [me waitStat:@"Deleting this account for security purposes..."];
            serve *bank = [serve new];
            bank.tagName = @"bDelete";
            bank.Delegate = self;
            [bank deleteBank:selectedId];
            verifyAttempts = 0;
            NSLog(@"delete bank id: %@",selectedId);
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hmmm.."message:@"Verification failed, please check the two deposit amounts again."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView sizeToFit];
            [alertView show];
        }
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload {
    menuTable = nil;
    addSourceMenu = nil;
    addBank = nil;
    addCard = nil;
    cancelSourceAdd = nil;
    detailsPopup = nil;
    hideDetails = nil;
    removeSource = nil;
    makePrimary = nil;
    updateExpire = nil;
    detailsTitle = nil;
    detailsDescriptor = nil;
    verifyView = nil;
    verifyAmount1 = nil;
    verifyAmount2 = nil;
    [super viewDidUnload];
}
@end
