//
//  refer.m
//  Nooch
//
//  Created by Preston Hults on 7/25/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "refer.h"
#import <QuartzCore/QuartzCore.h>

@interface refer ()

@end

@implementation refer

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [navBar setBackgroundImage:[UIImage imageNamed:@"TopNavBarBackground.png"]  forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [options setScrollEnabled:NO];
    options.layer.cornerRadius = 10;
    options.layer.borderColor = [core hexColor:@"000000"].CGColor;
    options.layer.borderWidth = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancel:(id)sender {
    [navCtrl dismissModalViewControllerAnimated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
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
    //UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(24, 4, 32, 32)];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void) listen:(NSString *)result tagName:(NSString *)tagName{
    
}

- (void)viewDidUnload {
    navBar = nil;
    options = nil;
    referCode = nil;
    [super viewDidUnload];
}
@end
