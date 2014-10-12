//  PINSettings.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2014 Nooch Inc. All rights reserved.

#import "PINSettings.h"
#import "Home.h"
#import "ResetPIN.h"
#import "ResetPassword.h"
@interface PINSettings ()
@property(nonatomic,strong)UISwitch *ri;
@property(nonatomic,strong)UISwitch *search;
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
    [self.navigationItem setTitle:@"Security Settings"];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashPageBckgrnd-568h@2x.png"]];
    backgroundImage.alpha = .25;
    [self.view addSubview:backgroundImage];
    
    UIButton *change_pin = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [change_pin setFrame:CGRectMake(20, 30, 280, 60)];
    [change_pin setTitle:@"Change PIN" forState:UIControlStateNormal];
    [change_pin setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.26) forState:UIControlStateNormal];
    change_pin.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [change_pin addTarget:self action:@selector(changepin) forControlEvents:UIControlEventTouchUpInside];
    [change_pin setStyleClass:@"button_blue"];
    [self.view addSubview:change_pin];
    
    UILabel *req_imm = [[UILabel alloc] initWithFrame:CGRectMake(-1, 100, 322, 56)];
    [req_imm setBackgroundColor:[UIColor whiteColor]];
    [req_imm setFont:[UIFont fontWithName:@"Roboto-regular" size:17]];
    [req_imm setText:@"    Require PIN Immediately"];
    [req_imm setTextColor:[Helpers hexColor:@"313233"]];
    req_imm.layer.borderColor = Rgb2UIColor(188, 190, 192, 0.85).CGColor;
    req_imm.layer.borderWidth = 1;
    [self.view addSubview:req_imm];
    
    self.ri = [[UISwitch alloc] initWithFrame:CGRectMake(260, 113, 40, 40)];
    [self.ri setOnTintColor:kNoochGreen];
    [self.ri addTarget:self action:@selector(req) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.ri];

    UILabel *info = [UILabel new];
    [info setFrame:CGRectMake(15, 158, 290, 30)];
    [info setNumberOfLines:0];
    [info setTextAlignment:NSTextAlignmentCenter];
    [info setFont:[UIFont fontWithName:@"Roboto-Light" size:14]];
    [info setTextColor:[Helpers hexColor:@"7f8185"]];
    [info setText:@"Require your PIN to enter the app."];
    [self.view addSubview:info];
    if ([[user objectForKey:@"requiredImmediately"] boolValue]) {
        [self.ri setOn:YES];
    }

    UIButton *change_password = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [change_password setFrame:CGRectMake(0, 240, 0, 0)];
    [change_password setStyleClass:@"button_blue"];
    [change_password setTitle:@"Change Password" forState:UIControlStateNormal];
    [change_password setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.26) forState:UIControlStateNormal];
    change_password.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [change_password addTarget:self action:@selector(changepass) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:change_password];
    
    UILabel *show_search = [[UILabel alloc] initWithFrame:CGRectMake(-1, 310, 322, 56)];
    [show_search setBackgroundColor:[UIColor whiteColor]];
    [show_search setFont:[UIFont fontWithName:@"Roboto-regular" size:17]];
    [show_search setText:@"    Show in Search"];
    [show_search setTextColor:[Helpers hexColor:@"313233"]];
    show_search.layer.borderColor = Rgb2UIColor(188, 190, 192, 0.85).CGColor;
    show_search.layer.borderWidth = 1;
    [self.view addSubview:show_search];
    
    self.search = [[UISwitch alloc] initWithFrame:CGRectMake(260, 323, 40, 40)];
    [self.search setOnTintColor:kNoochGreen];
    [self.search addTarget:self action:@selector(show_in_search) forControlEvents:UIControlEventValueChanged];
    [self.search setOn:YES];
    if ([user objectForKey:@"show_in_search"]) {
        if ([[user objectForKey:@"show_in_search"] isEqualToString:@"YES"]) [self.search setOn:YES];
        else [self.search setOn:NO];
    }
    [self.view addSubview:self.search];
    
    UILabel * info2 = [UILabel new];
    [info2 setFrame:CGRectMake(15, 370, 290, 42)];
    [info2 setNumberOfLines:0];
    [info2 setTextAlignment:NSTextAlignmentCenter];
    [info2 setFont:[UIFont fontWithName:@"Roboto-Light" size:14]];
    [info2 setTextColor:[Helpers hexColor:@"7f8185"]];
    [info2 setText:@"Show up when users search Nooch for nearby members."];
    [self.view addSubview:info2];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"Security Settings"];
    self.trackedViewName = @"PinSettings Screen";
}

- (void)changepass{
    ResetPassword * reset = [ResetPassword new];
    [self.navigationController presentViewController:reset animated:YES completion:nil];
}

-(void)changepin{
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

- (void) req
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

-(void)Error:(NSError *)Error
{
    /*UIAlertView * alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show]; */
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