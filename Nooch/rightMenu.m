//
//  rightMenu.m
//  Nooch
//
//  Created by Preston Hults on 5/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "rightMenu.h"

@interface rightMenu ()

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
	// Do any additional setup after loading the view.
    menuTable.scrollEnabled = NO;
    storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    verifyAttempts = 0;
}

-(void)viewDidAppear:(BOOL)animated{
    [menuTable reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
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
        return 3;
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
            cell.textLabel.text = @"NOOCH BALANCE";
            cell.textLabel.font=[UIFont systemFontOfSize:15];
            iv.image = [UIImage imageNamed:@"n_Icon.png"];
            UILabel *balance = [[UILabel alloc] initWithFrame:CGRectMake(213, 12, 100, 20)];
            balance.backgroundColor = [UIColor clearColor];
            balance.textColor = [UIColor whiteColor];
            balance.text = [NSString stringWithFormat:@"$%@",[[me usr] objectForKey:@"Balance"]];
            balance.font = [core nFont:@"Bold" size:15];
            [cell.contentView addSubview:balance];
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
            cell.textLabel.text = @"Add Funds";
            iv.image = [UIImage imageNamed:@"AddFunds.png"];
        }else if(indexPath.row == 2){
            [cell.contentView addSubview:arrow];
            cell.textLabel.text = @"Withdraw Funds";
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
        }
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            //BankName BankPicture
            if ([[[me usr] objectForKey:@"banks"] count] > 0) {
                [cell.contentView addSubview:arrow];
                NSLog(@"%@",[[[me usr] objectForKey:@"banks"] objectAtIndex:0]);
                NSDictionary *bank = [[[me usr] objectForKey:@"banks"] objectAtIndex:0];
                NSLog(@"bankkk%@",[bank objectForKey:@"BankAcctNumber"]);
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
    }
    [cell.contentView addSubview:iv];
    cell.backgroundColor=[UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
<<<<<<< HEAD
    }
=======
>>>>>>> 8fdd5080190ff4caefff31068f3a11d6bf166852
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 16 && buttonIndex == 1) {
        profileGO = YES;
        [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"settings"] animated:YES completion:nil];
       // [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"settings"] animated:YES];
    }else if(alertView.tag == 1 && buttonIndex == 1){
        [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"addBank"] animated:YES completion:nil];
       
    }
}

-(void)listen:(NSString *)result tagName:(NSString *)tagName{
    [me endWaitStat];
    NSDictionary *loginResult = [result JSONValue];
    if ([tagName isEqualToString:@"bPrimary"]) {
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
