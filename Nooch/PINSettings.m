//  PINSettings.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.

#import "PINSettings.h"
#import "Home.h"
#import "ResetPIN.h"
#import "ResetPassword.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface PINSettings () {
    UIScrollView * scrollView;
    UITableView * PinSettings;
    UITableView * PwSettings;
    UITableView * touchIdMenu;
}
@property(nonatomic,strong)UISwitch * ri;
@property(nonatomic,strong)UISwitch * search;
@property(nonatomic,strong)UISwitch * touchId;
@end

@implementation PINSettings

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
    self.navigationController.navigationBar.topItem.title = @"";
    //@"Security Settings"
    [self.navigationItem setTitle:NSLocalizedString(@"SecSettings_ScrnTitle", @"Security Settings Scrn Title")];
    [self.navigationItem setHidesBackButton:YES];

    [self.view setBackgroundColor:[Helpers hexColor:@"fdfdfd"]];

    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashPageBckgrnd-568h@2x.png"]];
    backgroundImage.alpha = .35;
    [self.view addSubview:backgroundImage];

    NSShadow * shadowNavText = [[NSShadow alloc] init];
    shadowNavText.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadowNavText.shadowOffset = CGSizeMake(0, -1.0);
    NSDictionary * titleAttributes = @{NSShadowAttributeName: shadowNavText};

    UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backtn)];

    UILabel * back_button = [UILabel new];
    [back_button setStyleId:@"navbar_back"];
    [back_button setUserInteractionEnabled:YES];
    [back_button addGestureRecognizer: backTap];
    back_button.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] attributes:titleAttributes];

    UIBarButtonItem * backBtn = [[UIBarButtonItem alloc] initWithCustomView:back_button];

    [self.navigationItem setLeftBarButtonItem:backBtn];

    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,
                                                            [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [scrollView setDelegate:self];

    if ([[assist shared] checkIfTouchIdAvailable] &&
        [[user objectForKey:@"requiredTouchId"] boolValue] == YES)
    {
        [scrollView setContentSize:CGSizeMake(320, 668)];
    }
    else if ([[assist shared] checkIfTouchIdAvailable] &&
             [[user objectForKey:@"requiredTouchId"] boolValue] == NO)
    {
        [scrollView setContentSize:CGSizeMake(320, 640)];
    }
    else
    {
        [scrollView setContentSize:CGSizeMake(320, 566)];
    }

    for (UIView *subview in self.view.subviews)
    {
        [subview removeFromSuperview];
        [scrollView addSubview:subview];
    }
    [self.view addSubview:scrollView];


    UILabel * PinHeader = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, 250, 25)];
    [PinHeader setStyleClass:@"refer_header"];
    [PinHeader setText:@"PIN "];
    [scrollView addSubview:PinHeader];

    PinSettings = [[UITableView alloc] initWithFrame:CGRectMake(-1, 45, 322, 100) style:UITableViewStylePlain];
    [PinSettings setStyleId:@"settings"];
    PinSettings.layer.borderColor = Rgb2UIColor(188, 190, 192, 0.85).CGColor;
    PinSettings.layer.borderWidth = 1;
    [PinSettings setDelegate:self];
    [PinSettings setDataSource:self];
    [PinSettings setScrollEnabled:NO];
    [scrollView addSubview:PinSettings];

    UILabel *info = [UILabel new];
    [info setFrame:CGRectMake(15, PinSettings.frame.origin.y + PinSettings.frame.size.height, 290, 34)];
    [info setNumberOfLines:0];
    [info setTextAlignment:NSTextAlignmentCenter];
    [info setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
    [info setTextColor:[Helpers hexColor:@"6c6e71"]];
    [info setText:NSLocalizedString(@"SecSettings_ReqPinInstruc", @"Security Settings require PIN instruction text")];
    [scrollView addSubview:info];

    UILabel * PwHeader = [[UILabel alloc] initWithFrame:CGRectMake(15, 190, 250, 25)];
    [PwHeader setStyleClass:@"refer_header"];
    [PwHeader setText:@"Password "];
    [scrollView addSubview:PwHeader];

    PwSettings = [[UITableView alloc] initWithFrame:CGRectMake(-1, 219, 322, 50) style:UITableViewStylePlain];
    [PwSettings setStyleId:@"settings"];
    PwSettings.layer.borderColor = Rgb2UIColor(188, 190, 192, 0.85).CGColor;
    PwSettings.layer.borderWidth = 1;
    [PwSettings setDelegate:self];
    [PwSettings setDataSource:self];
    [PwSettings setScrollEnabled:NO];
    [scrollView addSubview:PwSettings];

    UILabel * PrivacyHeader = [[UILabel alloc] initWithFrame:CGRectMake(15, 300, 250, 25)];
    [PrivacyHeader setStyleClass:@"refer_header"];
    [PrivacyHeader setText:@"Privacy "];
    [scrollView addSubview:PrivacyHeader];

    UILabel *show_search = [[UILabel alloc] initWithFrame:CGRectMake(-1, PrivacyHeader.frame.origin.y + PrivacyHeader.frame.size.height + 4, 322, 50)];
    [show_search setBackgroundColor:[UIColor whiteColor]];
    [show_search setFont:[UIFont fontWithName:@"Roboto-regular" size:17]];
    [show_search setText:NSLocalizedString(@"SecSettings_ShowInSrch", @"Security Settings show in search label")];
    [show_search setTextColor:[Helpers hexColor:@"313233"]];
    show_search.layer.borderColor = Rgb2UIColor(188, 190, 192, 0.85).CGColor;
    show_search.layer.borderWidth = 1;
    [scrollView addSubview:show_search];
    
    self.search = [[UISwitch alloc] initWithFrame:CGRectMake(260, show_search.frame.origin.y + 10, 40, 30)];
    self.search.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [self.search setOnTintColor:kNoochGreen];
    [self.search addTarget:self action:@selector(show_in_search) forControlEvents:UIControlEventValueChanged];
    [self.search setOn:YES];
    if ([user objectForKey:@"show_in_search"])
    {
        if ([[user objectForKey:@"show_in_search"] isEqualToString:@"YES"]) [self.search setOn:YES];
        else [self.search setOn:NO animated:YES];
    }
    [scrollView addSubview:self.search];

    UILabel * info2 = [UILabel new];
    [info2 setFrame:CGRectMake(10, show_search.frame.origin.y + show_search.frame.size.height, 300, 48)];
    [info2 setNumberOfLines:0];
    [info2 setTextAlignment:NSTextAlignmentCenter];
    [info2 setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
    [info2 setTextColor:[Helpers hexColor:@"6c6e71"]];
    [info2 setText:NSLocalizedString(@"SecSettings_ShowInSrchInstruc", @"Security Settings show in search instruction text")];
    [scrollView addSubview:info2];

    if ([[assist shared] checkIfTouchIdAvailable])
    {
        touchIdMenu = [UITableView new];
        if ([[user objectForKey:@"requiredTouchId"] boolValue] == YES)
        {
            [touchIdMenu setFrame:CGRectMake(-1, 442, 322, 100)];
            touchForPayments = YES;
        }
        else
        {
            [touchIdMenu setFrame:CGRectMake(-1, 442, 322, 50)];
            [user setObject:@"NO" forKey:@"requiredTouchId"];
            touchForPayments = NO;
        }
        [touchIdMenu setStyleId:@"settings"];
        touchIdMenu.layer.borderColor = Rgb2UIColor(188, 190, 192, 0.85).CGColor;
        touchIdMenu.layer.borderWidth = 1;
        [touchIdMenu setDelegate:self];
        [touchIdMenu setDataSource:self];
        [touchIdMenu setScrollEnabled:NO];
        [scrollView addSubview:touchIdMenu];
    }
    else if ([scrollView.subviews containsObject:touchIdMenu])
    {
        [touchIdMenu removeFromSuperview];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:NSLocalizedString(@"SecSettings_ScrnTitle", @"Security Settings Scrn Title")];
    self.screenName = @"Pin Settings Screen";
    self.artisanNameTag = @"Security Settings Screen";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == PinSettings)
    {
        return 2;
    }
    else if (tableView == PwSettings)
    {
        return 1;
    }
    else if (tableView == touchIdMenu)
    {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        UIView * selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = Rgb2UIColor(63, 171, 245, .45);
        cell.selectedBackgroundView = selectionColor;
    }

    if ([cell.contentView subviews])
    {
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }

    UILabel *title = [UILabel new];

    tableRowArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    [tableRowArrow setStyleClass:@"table_arrow"];
    [tableRowArrow setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-right"] forState:UIControlStateNormal];
    [tableRowArrow setTitleShadowColor:Rgb2UIColor(3, 5, 8, 0.1) forState:UIControlStateNormal];
    tableRowArrow.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);

    if (tableView == PinSettings)
    {
        [title setStyleClass:@"settings_table_label_unIndented"];
        if (indexPath.row == 0)
        {
            title.text = NSLocalizedString(@"SecSettings_ChgPinBtn", @"Security Settings change PIN btn text");

            tableRowArrow = [UIButton buttonWithType:UIButtonTypeCustom];
            [tableRowArrow setStyleClass:@"table_arrow"];
            [tableRowArrow setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-right"] forState:UIControlStateNormal];
            [tableRowArrow setTitleShadowColor:Rgb2UIColor(3, 5, 8, 0.1) forState:UIControlStateNormal];
            tableRowArrow.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            
            [cell.contentView addSubview:tableRowArrow];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
        else if (indexPath.row == 1)
        {
            title.text = NSLocalizedString(@"SecSettings_ReqPin", @"Security Settings require PIN immediately label");

            self.ri = [[UISwitch alloc] initWithFrame:CGRectMake(260, 10, 40, 30)];
            self.ri.transform = CGAffineTransformMakeScale(0.9, 0.9);
            [self.ri setOnTintColor:kNoochGreen];
            [self.ri addTarget:self action:@selector(req) forControlEvents:UIControlEventValueChanged];
            if ([[user objectForKey:@"requiredImmediately"] boolValue])
            {
                [self.ri setOn:YES animated:YES];
            }
            [cell.contentView addSubview:self.ri];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
    }

    else if (tableView == PwSettings)
    {
        [title setStyleClass:@"settings_table_label_unIndented"];
        title.text = NSLocalizedString(@"SecSettings_ChgPwBtn", @"Security Settings change PW btn text");

        [cell.contentView addSubview:tableRowArrow];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }

    else if (tableView == touchIdMenu)
    {
        UILabel *glyph = [UILabel new];
        [glyph setStyleClass:@"table_glyph"];

        if (indexPath.row == 0)
        {
            [title setStyleClass:@"settings_table_label"];
            title.text = @"Enable Touch ID";
            [glyph setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-lock"]];

            self.touchId = [[UISwitch alloc] initWithFrame:CGRectMake(260, 10, 40, 30)];
            self.touchId.transform = CGAffineTransformMakeScale(0.9, 0.9);
            [self.touchId setOnTintColor:kNoochGreen];
            [self.touchId addTarget:self action:@selector(touchIdTapped) forControlEvents:UIControlEventValueChanged];
            if ([[user objectForKey:@"requiredTouchId"] boolValue])
            {
                [self.touchId setOn:YES animated:YES];
            }
            else
            {
                [self.touchId setOn:NO animated:YES];
            }
            [cell.contentView addSubview:self.touchId];
        }
        else if (indexPath.row == 1)
        {
            [glyph setStyleId:@"table_glyph_touchID"];
            [glyph setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-share"]];

            UILabel *glyph2 = [UILabel new];
            [glyph2 setStyleClass:@"table_glyph_sm"];
            [glyph2 setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-usd"]];
            [cell.contentView addSubview:glyph2];

            [title setStyleClass:@"settings_table_label_smaller"];
            title.text = @"Require For Making Payments";

            if (touchForPayments == YES)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        /*else if (indexPath.row == 1)
         {
         [title setStyleClass:@"settings_table_label_unIndented"];
         title.text = @"Require For Logging In";
         
         if (touch1selected == YES)
         {
         cell.accessoryType = UITableViewCellAccessoryCheckmark;
         }
         else
         {
         cell.accessoryType = UITableViewCellAccessoryNone;
         }
         }*/

        [cell.contentView addSubview:glyph];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    [cell.contentView addSubview:title];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == PinSettings)
    {
        if (indexPath.row == 0)
        {
            [self changepin];
        }
    }
    else if (tableView == PwSettings)
    {
        if (indexPath.row == 0)
        {
            [self changepass];
        }
    }
    else if (tableView == touchIdMenu)
    {
        /*if (indexPath.row == 1)
        {
            if (touch1selected == YES)
                touch1selected = NO;
            else
                touch1selected = YES;
        }
        if (indexPath.row == 1)
        {
            if (touchForPayments == YES)
            {
                touchForPayments = NO;
            }
            else
            {
                touchForPayments = YES;
            }
        }*/
        if (indexPath.row != 0)
        {
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

-(void)backtn
{
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)changepass
{
    ResetPassword * reset = [ResetPassword new];
    [self.navigationController presentViewController:reset animated:YES completion:nil];
}

-(void)changepin
{
    ResetPIN * reset = [ResetPIN new];
    [self.navigationController presentViewController:reset animated:YES completion:nil];
}

-(void)show_in_search
{
    self.search.isOn ? [user setObject:@"YES" forKey:@"show_in_search"] : [user setObject:@"NO" forKey:@"show_in_search"];
    serve * set_search = [serve new];
    [set_search setDelegate:self];
    [set_search setTagName:@"set_search"];
    [set_search show_in_search:self.search.isOn ? YES : NO];
}

- (void)req
{
    if ([self.ri isOn])
    {
        serve * serveOBJ = [serve new];
        [serveOBJ setTagName:@"requiredImmediately"];
        [serveOBJ setDelegate:self];
        [serveOBJ SaveImmediateRequire:[self.ri isOn]];
        [user setObject:@"YES" forKey:@"requiredImmediately"];
    }
    else
    {
        serve * serveOBJ = [serve new];
        [serveOBJ setTagName:@"requiredImmediately"];
        [serveOBJ setDelegate:self];
        [serveOBJ SaveImmediateRequire:[self.ri isOn]];
        [user setObject:@"NO" forKey:@"requiredImmediately"];
    }
}

- (void)touchIdTapped
{
    NSLog(@"touchIdTapped meathod started");

    if ([[assist shared] checkIfTouchIdAvailable])
    {
        LAContext *context = [[LAContext alloc] init];
        
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:@"Just making sure you the owner of this device!"
                          reply:^(BOOL success, NSError *error) {
                              if (success)
                              {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self toggleTableExpandContract];
                                  });
                              }
                              else if (error)
                              {
                                  NSLog(@"PinSettings -> TouchID Error is: %ld",(long)error.code);
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      NSString * alertBody, * alertTitle;
                                      if (error.code == LAErrorUserCancel || error.code == LAErrorSystemCancel)
                                      {
                                          alertTitle = @"TouchID Cancelled";
                                          alertBody = @"You have TouchID turned on for making payments. To turn this off, please go to Nooch's settings and select \"Security Settings\".";
                                      }
                                      else if (error.code == LAErrorTouchIDNotAvailable)
                                      {
                                          alertTitle = @"TouchID Not Available";
                                          alertBody = @"";
                                      }
                                      else if (error.code == LAErrorUserFallback)
                                      {
                                          alertTitle = @"TouchID Password Not Set";
                                          alertBody = @"Please try verifying your fingerprint again.";
                                      }
                                      else if (error.code == LAErrorAuthenticationFailed)
                                      {
                                          alertTitle = @"Oh No!";
                                          alertBody = @"It seems like you are not the device owner!\n\nPlease try verifying your fingerprint again.";
                                      }
                                      else
                                      {
                                          alertTitle = @"TouchID Error";
                                          alertBody = @"There was a problem verifying your identity. Please try again!";
                                      }

                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                                      message:alertBody
                                                                                     delegate:nil
                                                                            cancelButtonTitle:@"Ok"
                                                                            otherButtonTitles:nil];
                                      [alert show];
                                      [self resetTouchIdSwitch];
                                  });
                                  return;
                              }

                              
                              else
                              {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh"
                                                                                      message:@"You are not the device owner."
                                                                                     delegate:nil
                                                                            cancelButtonTitle:@"Ok"
                                                                            otherButtonTitles:nil];
                                      [alert show];
                                      [self resetTouchIdSwitch];
                                  });
                              }
                              return;
                          }];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"TouchID does not seem to be available on this device \n(...which makes one wonder how you would even see this message)."
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert setTag:11];
            [alert show];
        });

        if (![self.touchId isOn])
        {
            [user setObject:@"YES" forKey:@"requiredTouchId"];
            [self toggleTableExpandContract];
        }
        else
        {
            [self resetTouchIdSwitch];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Checkpoint #1");
    if (alertView.tag == 11)
    {
        NSLog(@"Checkpoint #2");
        if ([scrollView.subviews containsObject:touchIdMenu])
        {
            NSLog(@"Checkpoint #3");
            [touchIdMenu removeFromSuperview];
            [user setObject:@"NO" forKey:@"requiredTouchId"];
        }
    }
}

-(void)toggleTableExpandContract
{
    NSString * alertBody;
    if ([[user objectForKey:@"requiredTouchId"] boolValue] == YES)
    {
        [UIView beginAnimations:@"contractTable" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        [scrollView setContentSize:CGSizeMake(320, 630)];
        [touchIdMenu setFrame:CGRectMake(-1, touchIdMenu.frame.origin.y, 322, 50)];
        [UIView commitAnimations];
        
        [user setObject:@"NO" forKey:@"requiredTouchId"];
        
        alertBody = @"TouchID is now turned OFF for your Nooch account.";
    }
    else
    {
        [UIView beginAnimations:@"expandTable" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        [scrollView setContentSize:CGSizeMake(320, 675)];
        [touchIdMenu setFrame:CGRectMake(-1, touchIdMenu.frame.origin.y, 322, 100)];
        [UIView commitAnimations];
        
        [user setObject:@"YES" forKey:@"requiredTouchId"];
        
        NSMutableArray * rows = [[NSMutableArray alloc] init];
        
        NSIndexPath * row1 = [NSIndexPath indexPathForRow:1 inSection:0];
        NSIndexPath * row2 = [NSIndexPath indexPathForRow:2 inSection:0];
        [rows addObject:row1];
        [rows addObject:row2];
        
        alertBody = @"TouchID is now turned ON for your Nooch account.";
        
        //[touchIdMenu reloadRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
        //[touchIdMenu reloadData];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                    message:alertBody
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];

    [self resetTouchIdSwitch];
}

-(void)resetTouchIdSwitch
{
    if ([[user objectForKey:@"requiredTouchId"] boolValue] == YES)
    {
        [self.touchId setOn:YES animated:YES];
    }
    else
    {
        [self.touchId setOn:NO animated:YES];
    }
}

-(void)Error:(NSError *)Error
{
    UIAlertView * alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    if ([tagName isEqualToString:@"requiredImmediately"])
    {
        NSError * error;
        Dictresponse = [NSJSONSerialization
                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                        options:kNilOptions
                        error:&error];
    }
    if ([tagName isEqualToString:@"set_search"])
    {
        NSError * error;
        Dictresponse = [NSJSONSerialization
                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                        options:kNilOptions
                        error:&error];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end