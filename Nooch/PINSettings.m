//
//  PINSettings.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "PINSettings.h"
#import "Home.h"
#import "ResetPIN.h"
#import "ResetPassword.h"
@interface PINSettings ()
@property(nonatomic,strong)UISwitch *ri;
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
    
    UIButton *change_pin = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [change_pin setFrame:CGRectMake(20, 50, 280, 60)];
    [change_pin setTitle:@"Change PIN" forState:UIControlStateNormal];
    [change_pin setTitleColor:kNoochLight forState:UIControlStateNormal];
    [change_pin.titleLabel setFont:kNoochFontBold];
    change_pin.layer.cornerRadius=5.0f;
    
    [change_pin addTarget:self action:@selector(changepin) forControlEvents:UIControlEventTouchUpInside];
    [change_pin setStyleClass:@"button_green"];
    [self.view addSubview:change_pin];
    
    UILabel *req_imm = [[UILabel alloc] initWithFrame:CGRectMake(-1, 140, 322, 60)];
    [req_imm setFont:[UIFont fontWithName:@"Roboto-Light" size:17]];
    [req_imm setText:@"   Require Immediately"];
    [req_imm setTextColor:kNoochBlue];
    req_imm.layer.borderColor = [Helpers hexColor:@"BCBEC0"].CGColor;
    req_imm.layer.borderWidth = 1;
    [self.view addSubview:req_imm];
    
    self.ri = [[UISwitch alloc] initWithFrame:CGRectMake(260, 155, 40, 40)];
    [self.ri setTintColor:kNoochGrayLight];
    [self.ri addTarget:self action:@selector(req) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.ri];
    
    UILabel *info = [UILabel new];
    [info setFrame:CGRectMake(10, 205, 300, 60)];
    [info setNumberOfLines:0];
    [info setTextAlignment:NSTextAlignmentCenter];
    [info setFont:[UIFont fontWithName:@"Roboto-Light" size:14]];
    [info setTextColor:[Helpers hexColor:@"939598"]];
    [info setText:@"Require a passcode even when switching apps for a short time"];
    [self.view addSubview:info];
    NSLog(@"%@",[user objectForKey:@"requiredImmediately"]);
    if ([[user objectForKey:@"requiredImmediately"] boolValue]) {
        [self.ri setOn:YES];
    }
    
    UIButton *change_password = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [change_password setFrame:CGRectMake(0, 280, 0, 0)];
    [change_password setStyleClass:@"button_green"];
    [change_password setTitle:@"Change Password" forState:UIControlStateNormal];
    [change_password addTarget:self action:@selector(changepass) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:change_password];
}

- (void)changepass{
    ResetPassword *reset = [ResetPassword new];
    [self.navigationController pushViewController:reset animated:YES];
}

-(void)changepin{
    ResetPIN*reset=[ResetPIN new];
    [self.navigationController presentViewController:reset animated:YES completion:nil];
    
}


- (void) req
{
    if ([self.ri isOn])
    {
        serve*serveOBJ=[serve new];
        [serveOBJ setTagName:@"requiredImmediately"];
        [serveOBJ setDelegate:self];
        [serveOBJ SaveImmediateRequire:[self.ri isOn]];
        //SaveImmediateRequire
        [user setObject:@"YES" forKey:@"requiredImmediately"];
    }
    else
    {
        serve*serveOBJ=[serve new];
        [serveOBJ setTagName:@"requiredImmediately"];
        [serveOBJ setDelegate:self];
        [serveOBJ SaveImmediateRequire:[self.ri isOn]];
        [user setObject:@"NO" forKey:@"requiredImmediately"];
    }
}


#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    if ([tagName isEqualToString:@"requiredImmediately"]) {
        NSError* error;
        Dictresponse = [NSJSONSerialization
                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                        options:kNilOptions
                        error:&error];
        NSLog(@"%@",Dictresponse);
        if ([[Dictresponse valueForKey:@"Result"] isEqualToString:@"success"]) {
            
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
