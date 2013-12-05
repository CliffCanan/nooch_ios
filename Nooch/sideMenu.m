//
//  sideMenu.m
//  Nooch
//
//  Created by Preston Hults on 5/1/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "sideMenu.h"
#import <QuartzCore/QuartzCore.h>
#import "SBJSON.h"
#import "JSON.h"
@interface sideMenu ()<UIAlertViewDelegate>

@end



@implementation sideMenu

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
    
    arrWithrawalOptions=[[NSMutableArray alloc]init];
    isWithdrawalSelected=NO;
    [arrWithrawalOptions addObject:@"HOME"];
    [arrWithrawalOptions addObject:@"Transaction History"];
    [arrWithrawalOptions addObject:@"Auto Withdrawal"];
    menuTable.backgroundColor=[UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
	// Do any additional setup after loading the view.
    storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    //menuPopup.backgroundColor = [core hexColor:@"505761"];
    //menuPopup.alpha = 0.93;
    hist = [storyboard instantiateViewControllerWithIdentifier:@"history"];
    
}
-(void)listen:(NSString *)result tagName:(NSString *)tagName
{
    
       NSArray*arr=[result JSONValue];
    NSLog(@"%@",dictResult);
    if ([tagName isEqualToString:@"withdrawOptions"])
    {
       // NSLog(@"response %@",[dictResult valueForKey:@"Result"]);
        arrAutoWithdrawalF=[arr copy];
        NSLog(@"%@",arrAutoWithdrawalF);
        
        serve *serveOBJ=[serve new];
        serveOBJ.Delegate=self;
        serveOBJ.tagName=@"Triggers";
        [serveOBJ GetAllWithdrawalTrigger];
        
    }
    else if ([tagName isEqualToString:@"Triggers"])
    {
        arrAutoWithdrawalT=[arr copy];
        NSLog(@"%@",arrAutoWithdrawalT);
        

    }
    else if ([tagName isEqualToString:@"SaveWithdrawal"])
    {
        dictResponse=[result JSONValue];
        NSLog(@"%@",[[dictResponse valueForKey:@"SaveFrequencyResult"] valueForKey:@"Result"]);
        if ([[[dictResponse valueForKey:@"SaveFrequencyResult"] valueForKey:@"Result"]isEqualToString:@"Saved Successfully"]) {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:[[dictResponse valueForKey:@"SaveFrequencyResult"] valueForKey:@"Result"] delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
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

-(void)viewWillAppear:(BOOL)animated{
    serve*serveOBJ=[serve new];
    serveOBJ.tagName=@"withdrawOptions";
    [serveOBJ GetAllWithdrawalFrequency];
    serveOBJ.Delegate=self;
    

    [emailDisplay setFont:[core nFont:@"Regular" size:14]];
    [nameDisplay setFont:[core nFont:@"Medium" size:20]];
    [versionNum setFont:[core nFont:@"Regular" size:10]];
    [versionNum setText:[NSString stringWithFormat:@"Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [emailDisplay setText:[[me usr] objectForKey:@"email"]];
    [nameDisplay setText:[NSString stringWithFormat:@"%@ %@",[[me usr] objectForKey:@"firstName"],[[me usr] objectForKey:@"lastName"]]];

    [firstButton.layer setBorderWidth:1.0f]; [firstButton.layer setBorderColor:[core hexColor:@"505761"].CGColor]; [firstButton.layer setCornerRadius:10.0f]; [firstButton setClipsToBounds:YES];
    [secondButton.layer setBorderWidth:1.0f]; [secondButton.layer setBorderColor:[core hexColor:@"505761"].CGColor]; [secondButton.layer setCornerRadius:10.0f]; [secondButton setClipsToBounds:YES];
    [thirdButton.layer setBorderWidth:1.0f]; [thirdButton.layer setBorderColor:[core hexColor:@"505761"].CGColor]; [thirdButton.layer setCornerRadius:10.0f]; [thirdButton setClipsToBounds:YES];
    [fourthButton.layer setBorderWidth:1.0f]; [fourthButton.layer setBorderColor:[core hexColor:@"505761"].CGColor]; [fourthButton.layer setCornerRadius:10.0f]; [fourthButton setClipsToBounds:YES];
    [cancelButton.layer setBorderWidth:1.0f]; [cancelButton.layer setBorderColor:[core hexColor:@"505761"].CGColor]; [cancelButton.layer setCornerRadius:10.0f]; [cancelButton setClipsToBounds:YES];
    [cancelButton setTitleColor:[core hexColor:@"FFFFFF"] forState:UIControlStateNormal]; cancelButton.backgroundColor = [core hexColor:@"505761"];
    [firstButton setTitleColor:[core hexColor:@"242e33"] forState:UIControlStateNormal]; firstButton.backgroundColor = [core hexColor:@"FFFFFF"];
    [secondButton setTitleColor:[core hexColor:@"242e33"] forState:UIControlStateNormal]; secondButton.backgroundColor = [core hexColor:@"FFFFFF"];
    [thirdButton setTitleColor:[core hexColor:@"242e33"] forState:UIControlStateNormal]; thirdButton.backgroundColor = [core hexColor:@"FFFFFF"];
    [fourthButton setTitleColor:[core hexColor:@"242e33"] forState:UIControlStateNormal]; fourthButton.backgroundColor = [core hexColor:@"FFFFFF"];
    [menuPopup setBackgroundColor:[core hexColor:@"3fabe1"]];

    [firstButton.titleLabel setFont:[core nFont:@"Medium" size:18]]; [secondButton.titleLabel setFont:[core nFont:@"Medium" size:18]]; [thirdButton.titleLabel setFont:[core nFont:@"Medium" size:18]];
    [fourthButton.titleLabel setFont:[core nFont:@"Medium" size:18]]; [cancelButton.titleLabel setFont:[core nFont:@"Medium" size:18]];

    [privacyButton.layer setBorderWidth:1.0f]; [privacyButton.layer setBorderColor:[core hexColor:@"505761"].CGColor]; [privacyButton.layer setCornerRadius:10.0f]; [privacyButton setClipsToBounds:YES];
    [termsButton.layer setBorderWidth:1.0f]; [termsButton.layer setBorderColor:[core hexColor:@"505761"].CGColor]; [termsButton.layer setCornerRadius:10.0f]; [termsButton setClipsToBounds:YES];
    [cancelLegal.layer setBorderWidth:1.0f]; [cancelLegal.layer setBorderColor:[core hexColor:@"505761"].CGColor]; [cancelLegal.layer setCornerRadius:10.0f]; [cancelLegal setClipsToBounds:YES];
    [cancelLegal setTitleColor:[core hexColor:@"FFFFFF"] forState:UIControlStateNormal]; cancelLegal.backgroundColor = [core hexColor:@"505761"];
    [privacyButton setTitleColor:[core hexColor:@"242e33"] forState:UIControlStateNormal]; privacyButton.backgroundColor = [core hexColor:@"FFFFFF"];
    [termsButton setTitleColor:[core hexColor:@"242e33"] forState:UIControlStateNormal]; termsButton.backgroundColor = [core hexColor:@"FFFFFF"];
    [legalInfoMenu setBackgroundColor:[core hexColor:@"3fabe1"]];

    [privacyButton.titleLabel setFont:[core nFont:@"Medium" size:18]]; [termsButton.titleLabel setFont:[core nFont:@"Medium" size:18]]; [cancelLegal.titleLabel setFont:[core nFont:@"Medium" size:18]];

    //[self.view.window addGestureRecognizer:self.slidingViewController.panGesture];

    [menuTable reloadData];
    [navCtrl.view endEditing:YES];
}


-(void)viewWillDisappear:(BOOL)animated{
    if ([Switch isOn]) {
        
        if ([dictSelectedWithdrawal count]==0) {
            SelectedOption=@"None";
            
        }
        if ([arrWithrawalOptions count]>3) {
            for (int i=0; i<countsubRecords; i++) {
                [arrWithrawalOptions removeLastObject];
            }
            
            [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    //[[[navCtrl.viewControllers objectAtIndex:0] view] addGestureRecognizer:self.slidingViewController.panGesture];
}

-(void)hideMenu{
    [self.slidingViewController resetTopView];
    //[self.view.window removeGestureRecognizer:close];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
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
        title.text = @"ACCOUNT";
    }else if(section == 1){
        title.text =  @"DISCOVER";
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
        return @"ACCOUNT";
    }else if(section == 1){
        return @"DISCOVER";
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
        return 1;
    }else if(section == 2){
        return 3;
    }else if(section == 3){
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
    cell.indentationLevel = 1;
    cell.indentationWidth = 40;
    cell.textLabel.font = [core nFont:@"Regular" size:18.0];
    cell.textLabel.textColor = [core hexColor:@"FFFFFF"];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 32, 32)];
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(230, 13, 12, 18)];
    arrow.image = [UIImage imageNamed:@"Arrow.png"];
    if (indexPath.section == 0) {
        cell.textLabel.font = [core nFont:@"Medium" size:18.0];
        if (indexPath.row == 0) {
            cell.detailTextLabel.text=@"";
            cell.textLabel.text = [arrWithrawalOptions objectAtIndex:indexPath.row];
            iv.image = [UIImage imageNamed:@"n_Icon.png"];
        }else if(indexPath.row == 1){
           
            if ([[me usr] objectForKey:@"lastSeen"]) {
                bool found = NO;
                newTransfers = 0;
                for (NSDictionary *dict in [me hist]) {
                    if ([[[me usr] objectForKey:@"lastSeen"] isKindOfClass:[NSNull class]]) {
                        break;
                    }
                    if ([[[me usr] objectForKey:@"lastSeen"] length] == 0) {
                        break;
                    }
                    if ([[[me usr] objectForKey:@"lastSeen"] isEqualToString:[dict objectForKey:@"TransactionId"]]) {
                        found = YES;
                        break;
                    }
                    if ([[dict objectForKey:@"TransactionType"] isKindOfClass:[NSNull class]] ||
                        [[dict objectForKey:@"RecepientId"] isKindOfClass:[NSNull class]])
                        continue;
                    if ([[dict objectForKey:@"TransactionType"] isEqualToString:@"Received"] ||
                        (![[dict objectForKey:@"RecepientId"] isEqualToString:[[me usr] objectForKey:@"MemberId"]]
                         && [[dict objectForKey:@"TransactionType"] isEqualToString:@"Request"])) {
                        newTransfers++;
                    }
                }
                if (!found) {
                    newTransfers = 0;
                }
                UIImageView *note = [[UIImageView alloc] initWithFrame:CGRectMake(220, 10, 25, 25)];
                switch (newTransfers) {
                    case 0:
                        break;
                    case 1:
                        note.image = [UIImage imageNamed:@"Notification_1.png"];
                        break;
                    case 2:
                        note.image = [UIImage imageNamed:@"Notification_2.png"];
                        break;
                    case 3:
                        note.image = [UIImage imageNamed:@"Notification_3.png"];
                        break;
                    case 4:
                        note.image = [UIImage imageNamed:@"Notification_4.png"];
                        break;
                    case 5:
                        note.image = [UIImage imageNamed:@"Notification_5.png"];
                        break;
                    case 6:
                        note.image = [UIImage imageNamed:@"Notification_6.png"];
                        break;
                    default:
                        break;
                }
                if (newTransfers > 0) {
                    [cell.contentView addSubview:note];
                }
            }
            cell.detailTextLabel.text=@"";
            cell.textLabel.text = [arrWithrawalOptions objectAtIndex:indexPath.row];
            iv.image = [UIImage imageNamed:@"Clock_Icon.png"];
           
        }
        else if (indexPath.row==2)
        {
            
            cell.textLabel.text = [arrWithrawalOptions objectAtIndex:indexPath.row];
            cell.detailTextLabel.textColor=[UIColor whiteColor];
            Switch = [[UISwitch alloc] initWithFrame:CGRectMake(200, 5, 70, 30)];
            Switch.tag=12000;
            
            if ([SelectedOption isEqualToString:@"Frequency"]||[SelectedOption isEqualToString:@"Triggers"])
            {
               [Switch setOn:YES];
                if (dictSelectedWithdrawal) {
                    NSString*option=[dictSelectedWithdrawal valueForKey:SelectedOption];
                    NSArray*arrSeparate=[[dictSelectedWithdrawal valueForKey:option] componentsSeparatedByString:@" "];
                    
                    cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ $%@",[[dictSelectedWithdrawal valueForKey:option] substringToIndex:[[dictSelectedWithdrawal valueForKey:option]length]-2],[arrSeparate lastObject]];
                    SelectedSubOption=[dictSelectedWithdrawal valueForKey:option];

                }
                else
                {
                     cell.detailTextLabel.text=@"";
                }
                               //[NSString stringWithFormat:@"%d",indexPath.row]
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
                 cell.textLabel.text=[[arrWithrawalOptions objectAtIndex:indexPath.row] substringToIndex:[[arrWithrawalOptions objectAtIndex:indexPath.row] length]-3];
            }
            else{
                cell.textLabel.text=[arrWithrawalOptions objectAtIndex:indexPath.row] ;
//                UITextField*textMyWithdrawal=[[UITextField alloc]initWithFrame:CGRectMake(120, 5, 100, 35)];
//                [textMyWithdrawal setPlaceholder:@"Enter Amount"];
//                textMyWithdrawal.textColor = [UIColor blackColor];
//                textMyWithdrawal.borderStyle = UITextBorderStyleRoundedRect;
//                textMyWithdrawal.font = [UIFont systemFontOfSize:15.0];
//                
//                textMyWithdrawal.backgroundColor = [UIColor whiteColor];
//                [cell.contentView addSubview:textMyWithdrawal];

            }
            cell.detailTextLabel.text=@"";
            if (indexPath.row==7) {
                
                if([dictSelectedWithdrawal valueForKey:[NSString stringWithFormat:@"%d",indexPath.row]]){
                    UILabel*lbl=[[UILabel alloc]initWithFrame:CGRectMake(200, 5, 100, 35)];
                    lbl.textColor=[UIColor whiteColor];
                    lbl.backgroundColor=[UIColor clearColor];
                    lbl.text=[NSString stringWithFormat:@"%@",[dictSelectedWithdrawal valueForKey:[NSString stringWithFormat:@"%d",indexPath.row]]];
                    [cell.contentView addSubview:lbl];
                }
           
            
            }
            else
            {
                UIButton*check=[UIButton buttonWithType:UIButtonTypeCustom];
                [check  setTag:indexPath.row];
                
                if([dictSelectedWithdrawal valueForKey:[NSString stringWithFormat:@"%d",indexPath.row]])
                {
                    [check setBackgroundColor:[UIColor greenColor]];
                    [check setTitle:@"check" forState:UIControlStateNormal];
                }
                else
                {
                    [check setBackgroundColor:[UIColor orangeColor]];
                    [check setTitle:@"uncheck" forState:UIControlStateNormal];
                }
                [check setFrame:CGRectMake(200, 5, 70, 30)];
                
                [check addTarget:self action:@selector(checkButtonCLicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:check];
            }
            cell.detailTextLabel.text=@"";
        }
    }else if(indexPath.section == 1){
        [cell.contentView addSubview:arrow];
        if (indexPath.row == 0) {
            cell.detailTextLabel.text=@"";

            cell.textLabel.text = @"Donate to a Cause";
            iv.image = [UIImage imageNamed:@"Ribbon_Icon.png"];
            //cell.textLabel.text = @"Pay My Rent";
            //iv.image = [UIImage imageNamed:@"Apt_Icon.png"];
        }else if(indexPath.row == 1){
            //cell.textLabel.text = @"Donate to a Cause";
            //iv.image = [UIImage imageNamed:@"Ribbon_Icon.png"];
        }
    }else if(indexPath.section == 2){
        [cell.contentView addSubview:arrow];
        if (indexPath.row == 0) {
            cell.detailTextLabel.text=@"";

            cell.textLabel.text = @"Refer a Friend";
            iv.image = [UIImage imageNamed:@"ReferAFriend_Icon.png"];
        }else if(indexPath.row == 1){
            cell.detailTextLabel.text=@"";

            cell.textLabel.text = @"Social Networks";
            iv.image = [UIImage imageNamed:@"Facebook_Icon.png"];
        }else if(indexPath.row == 2){
            cell.detailTextLabel.text=@"";

            cell.textLabel.text = @"Rate Nooch";
            iv.image = [UIImage imageNamed:@"RateNooch_Icon.png"];
        }
    }else if(indexPath.section == 3){
        [cell.contentView addSubview:arrow];
        if (indexPath.row == 0) {
            cell.detailTextLabel.text=@"";

            cell.textLabel.text = @"How Nooch Works";
            iv.image = [UIImage imageNamed:@"Help_Icon.png"];
        }else if(indexPath.row == 1){
            cell.detailTextLabel.text=@"";

            cell.textLabel.text = @"Contact Support";
            iv.image = [UIImage imageNamed:@"Diamonds_Icon.png"];
        }else if(indexPath.row == 2){
            cell.detailTextLabel.text=@"";

            cell.textLabel.text =  @"Limits & Fees";
            iv.image = [UIImage imageNamed:@"LimitsAndFees_Icon.png"];
        }else if(indexPath.row == 3) {
            cell.textLabel.text = @"Legal Info";
            cell.detailTextLabel.text=@"";

            iv.image = [UIImage imageNamed:@"LegalStuff_Icon.png"];
        }
    }
    [cell.contentView addSubview:iv];
    cell.backgroundColor=[UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{ //72bf44
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if ([[[navCtrl viewControllers] objectAtIndex:[[navCtrl viewControllers] count] -1] isKindOfClass:[NoochHome class]]) {
                [self.slidingViewController resetTopView];
                return;
            }
            NSLog(@"%@",curpage);
            [navCtrl popToRootViewControllerAnimated:NO];
            [self.slidingViewController resetTopView];
            curpage = @"noochHome";
        }else if(indexPath.row == 1){
            if ([[[navCtrl viewControllers] objectAtIndex:[[navCtrl viewControllers] count] -1] isKindOfClass:[history class]]) {
                [self.slidingViewController resetTopView];
                return;
            }
            NSLog(@"%@",curpage);
            curpage = @"history";
            [navCtrl pushViewController:hist animated:NO];
            [self.slidingViewController resetTopView];
            /*[self.slidingViewController resetTopViewWithAnimations:nil onComplete:^{
                [navCtrl pushViewController:hist animated:NO];
            }];*/
            //[self.slidingViewController resetTopView];
            //[navCtrl pushViewController:hist animated:NO];
            //[self.slidingViewController.topViewController presentViewController:hist animated:NO completion:nil];
        }
        else if(indexPath.row==2)
        {
            if ([Switch isOn]) {
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
                    if ([[temp2 objectAtIndex:0]isEqualToString:@"Frequency"]) {
                        countsubRecords=0;
                        for (NSDictionary*dict in arrAutoWithdrawalF) {
                            countsubRecords++;
                            [arrWithrawalOptions addObject:[NSString stringWithFormat:@"%@ at %@",[dict valueForKey:@"Name"],[dict valueForKey:@"Time"]]];
                        }

                    }
                    else if ([[temp2 objectAtIndex:0]isEqualToString:@"Triggers"])
                    {
                        countsubRecords=0;
                        for (NSDictionary*dict in arrAutoWithdrawalT) {
                            countsubRecords++;
                            [arrWithrawalOptions addObject:[NSString stringWithFormat:@"%@ at %@",[dict valueForKey:@"Name"],[dict valueForKey:@"Time"]]];
                        }
                        [arrWithrawalOptions addObject:@"Custom Withdrawal"];
                        countsubRecords++;
                        
                    }
                    
                }
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
          //  [menuTable reloadData];
            }
        }
        else if(indexPath.row==7)
        {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"NoochMoney" message:@"Custom Withdrawal Between $10-$100" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];

            [alert setTag:12002];
            [alert show];
        }
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            causes = YES;
            [self.slidingViewController resetTopView];
            if (![curpage isKindOfClass:[NSNull class]]) {
                if ([curpage isEqualToString:@"history"])
                    [navCtrl popToRootViewControllerAnimated:NO];
            }
            
            curpage = @"noochHome";
            [[navCtrl.viewControllers objectAtIndex:0] performSelector:@selector(donate)];
            return;

            //pay rent
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Coming Soon" message:@"We're working with apartment complexes to let you pay your rent with Nooch. Stay tuned!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
        }else if(indexPath.row == 1){
            //donate
            causes = YES;
            [self.slidingViewController resetTopView];
            if (![curpage isKindOfClass:[NSNull class]]) {
                if ([curpage isEqualToString:@"history"])
                    [navCtrl popToRootViewControllerAnimated:NO];
            }
            
            curpage = @"noochHome";
            [[navCtrl.viewControllers objectAtIndex:0] performSelector:@selector(donate)];
            return;
        }
    }else if(indexPath.section == 2){
        if (indexPath.row == 0) {
            //invite
            [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"refer"] animated:YES completion:nil];
          //  [navCtrl presentModalViewController: animated:YES];
        }else if(indexPath.row == 1){
            //social networks
            [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"social"] animated:YES completion:nil];
           // [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"social"] animated:YES];
        }else if(indexPath.row == 2){
            //rate
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Pending App Store" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
        }
    }else if(indexPath.section == 3){
        if (indexPath.row == 0) {
            //tutorial
            if ([[[navCtrl viewControllers] objectAtIndex:[[navCtrl viewControllers] count] -1] isKindOfClass:[history class]]) {
                [navCtrl popToRootViewControllerAnimated:NO];
            }
            [self.slidingViewController resetTopView];
            [[navCtrl.viewControllers objectAtIndex:0] performSelector:@selector(showTutorial)];
        }else if(indexPath.row == 1){
            //contact support
            CGRect frame = CGRectMake(0, 480, 320, 300);
            if([[UIScreen mainScreen] bounds].size.height > 480){
                frame.origin.y = 600;
            }
            [menuPopup setFrame:frame];
            shadow = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 600)];
            [shadow setBackgroundColor:[UIColor blackColor]];
            [shadow setAlpha:0.0f];
            [shadow setUserInteractionEnabled:YES];
            [self.view.window addSubview:shadow];
            [self.view.window addSubview:menuPopup];
            [menuPopup setFrame:frame];
            firstButton.hidden = NO; secondButton.hidden = NO; thirdButton.hidden = NO; fourthButton.hidden = NO;
            [firstButton setTitle:@"Call Nooch" forState:UIControlStateNormal];
            [firstButton addTarget:self action:@selector(callSupport) forControlEvents:UIControlEventTouchUpInside];
            [secondButton setTitle:@"Email Nooch Support" forState:UIControlStateNormal];
            [secondButton addTarget:self action:@selector(emailSupport) forControlEvents:UIControlEventTouchUpInside];
            [thirdButton setTitle:@"Report a Bug" forState:UIControlStateNormal];
            [thirdButton addTarget:self action:@selector(reportBug) forControlEvents:UIControlEventTouchUpInside];
            [fourthButton setTitle:@"View Support Center" forState:UIControlStateNormal];
            [fourthButton addTarget:self action:@selector(viewFAQ) forControlEvents:UIControlEventTouchUpInside];
            [cancelButton setTitle:@"Nevermind" forState:UIControlStateNormal];
            [cancelButton addTarget:self action:@selector(hideActionMenu) forControlEvents:UIControlEventTouchUpInside];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            frame.origin.y = 180;
            if([[UIScreen mainScreen] bounds].size.height > 480){
                frame.origin.y = 280;
            }
            [menuPopup setFrame:frame];
            [shadow setAlpha:0.5f];
            [UIView commitAnimations];
        }else if(indexPath.row == 2){
            //limits/fees
            [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"limitsFees"] animated:YES completion:nil];
           // [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"limitsFees"] animated:YES];
        }else if(indexPath.row == 3) {
            CGRect frame = CGRectMake(0, 480, 320, 300);
            if([[UIScreen mainScreen] bounds].size.height > 480){
                frame.origin.y = 600;
            }
            [legalInfoMenu setFrame:frame];
            shadow = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 600)];
            [shadow setBackgroundColor:[UIColor blackColor]];
            [shadow setAlpha:0.0f];
            [shadow setUserInteractionEnabled:YES];
            [self.view.window addSubview:shadow];
            [self.view.window addSubview:legalInfoMenu];
            [privacyButton setTitle:@"Privacy Policy" forState:UIControlStateNormal];
            [privacyButton addTarget:self action:@selector(privacy) forControlEvents:UIControlEventTouchUpInside];
            [termsButton setTitle:@"Terms of Service" forState:UIControlStateNormal];
            [termsButton addTarget:self action:@selector(terms) forControlEvents:UIControlEventTouchUpInside];
            [cancelLegal setTitle:@"Nevermind" forState:UIControlStateNormal];
            [cancelLegal addTarget:self action:@selector(hideActionMenu) forControlEvents:UIControlEventTouchUpInside];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            frame.origin.y = 280;
            if([[UIScreen mainScreen] bounds].size.height > 480){
                frame.origin.y = 370;
            }
            [legalInfoMenu setFrame:frame];
            [shadow setAlpha:0.5f];
            [UIView commitAnimations];
        }
    }
}
-(void)checkButtonCLicked:(UIButton*)sender
{
    
    serve*serveOBJ=[serve new];
    serveOBJ.tagName=@"SaveWithdrawal";
    serveOBJ.Delegate=self;
    
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
        float value= [[[[arrAutoWithdrawalT objectAtIndex:tag-3] valueForKey:@"Name"] substringFromIndex:1] floatValue];
        [serveOBJ SaveFrequency:[[arrAutoWithdrawalT objectAtIndex:tag-3] valueForKey:@"Id"] type:SelectedOption frequency:value];
    }
    else
    {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"NoochMoney" message:@"Custom Withdrawal Between $10-$100" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        tagForFrequency=[sender tag];
        [alert setTag:12045];
        [alert show];
    }
    
    [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)changeSwitch:(id)sender{
    if ([sender tag]==12000) {
        if([sender isOn]){
             isWithdrawalSelected=YES;
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Withdrawal Options" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Frequency",@"Triggers", nil];
            [alert setTag:12003];
            
            [alert show];
            // Execute any code when the switch is ON
            NSLog(@"Switch is ON");
        }
        else{
            isWithdrawalSelected=NO;
            SelectedOption=@"None";
            if ([arrWithrawalOptions count]>3) {
                for (int i=0; i<countsubRecords; i++) {
                    [arrWithrawalOptions removeLastObject];
                }
            }
            [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];

            [dictSelectedWithdrawal removeAllObjects];
            // Execute any code when the switch is OFF
            NSLog(@"Switch is OFF");
        }

    }
    }
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag]==12003) {
        if (buttonIndex==0) {
            SelectedOption=@"None";
            [Switch setOn:NO animated:YES];
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            
        }
        else if(buttonIndex==1)
            
        {
            SelectedOption=@"Frequency";
            //[Switch setOn:YES animated:YES];
            //@"Daily at 5:00",@"Weekly at 5:00",@"Monthly at 5:00
            if ([arrWithrawalOptions count]>3) {
                for (int i=0; i<countsubRecords; i++) {
                    [arrWithrawalOptions removeLastObject];
                }
            }
            countsubRecords=0;
            for (NSDictionary*dict in arrAutoWithdrawalF) {
                countsubRecords++;
                [arrWithrawalOptions addObject:[NSString stringWithFormat:@"%@ at %@",[dict valueForKey:@"Name"],[dict valueForKey:@"Time"]]];
            }
            
            
            
            [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            

           [alertView dismissWithClickedButtonIndex:1 animated:YES];
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
            [arrWithrawalOptions addObject:@"Custom Withdrawal"];
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
            [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"$%@",value.text] forKey:[NSString stringWithFormat:@"%d",7]];
            [dictSelectedWithdrawal setValue:[NSString stringWithFormat:@"%d",7] forKey:SelectedOption];
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
            [serveOBJ SaveFrequency:[[arrAutoWithdrawalF objectAtIndex:tagForFrequency-3] valueForKey:@"Id"] type:@"Frequency" frequency:[value.text floatValue]];
            [menuTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        }
    }
}
-(void)privacy{
    [self hideActionMenu];
    [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"privacy"] animated:YES completion:nil];
    //[navCtrl presentModalViewController: animated:YES];
}
-(void)terms{
    [self hideActionMenu];
    [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"terms"] animated:YES completion:nil];
 //   [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"terms"] animated:YES];
}

-(void)hideActionMenu{
    CGRect frame = menuPopup.frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    frame.origin.y = 600;
    [menuPopup setFrame:frame];
    frame = legalInfoMenu.frame;
    frame.origin.y = 600;
    [shadow setAlpha:0.0f];
    [legalInfoMenu setFrame:frame];
    [UIView commitAnimations];
}

- (IBAction)settingsPush:(id)sender {
    [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"settings"] animated:YES completion:nil];
    //[navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"settings"] animated:YES];
    curpage = @"settings";
}

-(void)openView:(NSString *)uid{

    NSString *identifier = uid;

    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];

    [self.slidingViewController anchorTopViewOffScreenTo:ECLeft animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
    
}

- (IBAction)viewStats:(id)sender {
    [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"stats"] animated:YES completion:nil];
  //  [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"stats"] animated:YES];
}

- (void)viewFAQ {
    NSURL *webURL = [NSURL URLWithString:@"http://support.nooch.com"];
    [[UIApplication sharedApplication] openURL: webURL];
}
- (void)reportBug {
    if (![MFMailComposeViewController canSendMail]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't have a mail account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
        return;
    }
    [self hideActionMenu];
    mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setSubject:[NSString stringWithFormat:@"Bug Report: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [mailComposer setMessageBody:@"" isHTML:NO];
    [mailComposer setToRecipients:[NSArray arrayWithObjects:@"bugs@nooch.com",nil]];
    [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:mailComposer animated:YES completion:nil];
   // [self presentModalViewController:mailComposer animated:YES];
}
- (void)emailSupport {
    if (![MFMailComposeViewController canSendMail]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't have a mail account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
        return;
    }
    [self hideActionMenu];
    mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [mailComposer setMessageBody:@"" isHTML:NO];
    [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
    [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
     [self presentViewController:mailComposer animated:YES completion:nil];
    //[self presentModalViewController:mailComposer animated:YES];
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
 //   [self dismissModalViewControllerAnimated:YES];
    if (result == MFMailComposeResultSent) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Thanks for the Feedback" message:@"Our scientists will study and consider these comments or suggestions to better the app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}
- (void)callSupport {

    if([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] || [[[UIDevice currentDevice] model] isEqualToString:@"iPad"])
    {
        NSString *phoneNumber = [[NSString alloc] initWithFormat:@"tel:8552696662"];
        NSURL *phoneNumberURL = [[NSURL alloc] initWithString:phoneNumber];
        [[UIApplication sharedApplication] openURL:phoneNumberURL];
    }
    else
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"This device doesn't support calling!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}
-(void)startSupportCall{
    NSString *phoneNumber = [[NSString alloc] initWithFormat:@"tel:8552696662"];
    NSURL *phoneNumberURL = [[NSURL alloc] initWithString:phoneNumber];
    [[UIApplication sharedApplication] openURL:phoneNumberURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    menuTable = nil;
    emailDisplay = nil;
    nameDisplay = nil;
    versionNum = nil;
    menuPopup = nil;
    firstButton = nil;
    secondButton = nil;
    thirdButton = nil;
    fourthButton = nil;
    cancelButton = nil;
    legalInfoMenu = nil;
    privacyButton = nil;
    termsButton = nil;
    cancelLegal = nil;
    [super viewDidUnload];
}
@end
