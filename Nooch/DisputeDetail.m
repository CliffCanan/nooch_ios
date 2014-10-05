//
//  DisputeDetail.m
//  Nooch
//
//  Created by Vicky Mathneja on 01/08/14.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import "DisputeDetail.h"
#import "Home.h"
#import "Register.h"
@interface DisputeDetail ()
@property(nonatomic,strong)UIButton*email_nooch;

@property(nonatomic,strong) UITextField *txtStatus;
@property(nonatomic,strong) UITextField *txtNotes;
@property(nonatomic,strong) UITextField *txtDate;
@property(nonatomic,strong) UITextField *txtID;
@property(nonatomic,strong) UITextField *txtReviewDate;
@property(nonatomic,strong) UITextField *txtResolvedD;
@property(nonatomic,strong) UILabel *lblNotes;
@property(nonatomic,strong) UITableView *list;
@property (nonatomic,strong) NSDictionary *disputeDetails;
@end

@implementation DisputeDetail
@synthesize email_nooch;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithData:(NSDictionary *)trans {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.disputeDetails = trans;
        NSLog(@"%@",self.disputeDetails);
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.trackedViewName = @"Dispute Detail Screen";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"";
    self.title=@"Dispute Details";
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashPageBckgrnd-568h@2x.png"]];
    backgroundImage.alpha = .25;
    [self.view addSubview:backgroundImage];

    self.txtStatus = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.txtStatus setTextAlignment:NSTextAlignmentRight];
    [self.txtStatus setBackgroundColor:[UIColor clearColor]];
    [self.txtStatus setDelegate:self];
    [self.txtStatus setStyleClass:@"table_view_cell_detailtext_1"];
    [self.txtStatus setStyleClass:@"bold"];
    [self.txtStatus setText:[NSString stringWithFormat:@"%@ ",[self.disputeDetails valueForKey:@"DisputeStatus"]]];
    [self.txtStatus setUserInteractionEnabled:NO];
    [self.txtStatus setTag:0];
    [self.view addSubview:self.txtStatus];
    
    self.txtID = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.txtID setTextAlignment:NSTextAlignmentRight];
    [self.txtID setBackgroundColor:[UIColor clearColor]];
    [self.txtID setDelegate:self];
    [self.txtID setStyleClass:@"table_view_cell_detailtext_1"];
    [self.txtID setText:[self.disputeDetails valueForKey:@"DisputeId"]];
    [self.txtID setUserInteractionEnabled:NO];
    [self.txtID setTag:0];
    [self.view addSubview:self.txtID];
    
    self.txtDate = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.txtDate setTextAlignment:NSTextAlignmentRight];
    [self.txtDate setBackgroundColor:[UIColor clearColor]];
    [self.txtDate setPlaceholder:@"Date Reported"];
    [self.txtDate setDelegate:self];
    [self.txtDate setKeyboardType:UIKeyboardTypeEmailAddress];
    [self.txtDate setStyleClass:@"table_view_cell_detailtext_1"];
    [self.txtDate setTag:1];
    [self.txtDate setText:[self.disputeDetails valueForKey:@"DisputeReportedDate"]];
    [self.view addSubview:self.txtDate];
    
    self.txtReviewDate = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.txtReviewDate setTextAlignment:NSTextAlignmentRight];
    [self.txtReviewDate setBackgroundColor:[UIColor clearColor]];
    [self.txtReviewDate setPlaceholder:@"Not Reviewed Yet"];
    [self.txtReviewDate setDelegate:self];
    [self.txtReviewDate setStyleClass:@"table_view_cell_detailtext_1"];
    [self.txtReviewDate setTag:2];
    [self.txtReviewDate setText:[self.disputeDetails valueForKey:@"DisputeReviewDate"]];
    [self.view addSubview:self.txtReviewDate];
    
    self.txtResolvedD = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.txtResolvedD setTextAlignment:NSTextAlignmentRight];
    [self.txtResolvedD setBackgroundColor:[UIColor clearColor]];
    [self.txtResolvedD setPlaceholder:@"Not Resolved Yet"];
    [self.txtResolvedD setDelegate:self];
    [self.txtResolvedD setKeyboardType:UIKeyboardTypeDefault];
    [self.txtResolvedD setStyleClass:@"table_view_cell_detailtext_1"];
    [self.txtResolvedD setTag:3];
    [self.txtResolvedD setText:[self.disputeDetails valueForKey:@"DisputeResolvedDate"]];

    self.txtNotes = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.txtNotes setTextAlignment:NSTextAlignmentRight];
    [self.txtNotes setBackgroundColor:[UIColor clearColor]];
    [self.txtNotes setPlaceholder:@"Notes"];
    [self.txtNotes setDelegate:self];
    [self.txtNotes setStyleClass:@"table_view_cell_detailtext_1"];
    if ([self.disputeDetails valueForKey:@"AdminNotes"] != NULL && ![[self.disputeDetails valueForKey:@"AdminNotes"] isKindOfClass:[NSNull class]]) {
        [self.txtNotes setText:[NSString stringWithFormat:@"%@ ",[self.disputeDetails valueForKey:@"AdminNotes"]]];
    }
    [self.txtNotes setUserInteractionEnabled:NO];
    [self.txtNotes setTag:4];
    [self.view addSubview:self.txtNotes];
    
    
    [self.view addSubview:self.txtResolvedD];
    self.list = [UITableView new];
    [self.list setFrame:CGRectMake(-1, 20, 322, 300)];
    self.list.layer.borderColor = Rgb2UIColor(188, 190, 192, 0.85).CGColor;
    self.list.layer.borderWidth = 1;
    [self.list setBackgroundColor:[UIColor whiteColor]];
    [self.list setDelegate:self];
    [self.list setDataSource:self];
    [self.list setRowHeight:50];
    [self.list setScrollEnabled:NO];
    [self.view addSubview:self.list];
    
    email_nooch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [email_nooch setFrame:CGRectMake(20, 365, 280,50)];
    [email_nooch setTitle:@"Email Nooch" forState:UIControlStateNormal];
    [email_nooch addTarget:self action:@selector(email_noochClicked:) forControlEvents:UIControlEventTouchUpInside];
    [email_nooch setStyleClass:@"button_blue"];
    [email_nooch setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.26) forState:UIControlStateNormal];
    email_nooch.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [email_nooch setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:email_nooch];

    // Do any additional setup after loading the view.
}

-(void)email_noochClicked:(id)sender
{
    if (![MFMailComposeViewController canSendMail])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't have an email account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
        return;
    }
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    mailComposer.navigationBar.tintColor=[UIColor whiteColor];
    [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [mailComposer setMessageBody:[NSString stringWithFormat:@"Dispute ID: %@",[self.disputeDetails valueForKey:@"DisputeId"]] isHTML:NO];
    [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
    [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:mailComposer animated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setDelegate:nil];
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
            
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            [alert setTitle:@"Email Draft Saved"];
            [alert show];
            break;
            
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            [alert setTitle:@"Email Sent Successfully"];
            [alert show];
            break;
            
        case MFMailComposeResultFailed:
            [alert setTitle:[error localizedDescription]];
            [alert show];
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        [cell.textLabel setTextColor:kNoochGrayLight];
        cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        cell.clipsToBounds = YES;
    }
    if (indexPath.row == 0)
    {
        UILabel *Status = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, 50)];
        [Status setBackgroundColor:[UIColor clearColor]];
        [Status setText:@"Status"];
        [Status setStyleClass:@"table_view_cell_textlabel_1"];
        [cell.contentView addSubview:Status];
        [cell.contentView addSubview:self.txtStatus];
        
        if ([self.txtStatus.text rangeOfString:@"Resolved"].location != NSNotFound) {
            [self.txtStatus setTextColor:kNoochGreen];
        }
        else {
              [self.txtStatus setTextColor:kNoochRed];
        }
        
        [cell setUserInteractionEnabled:NO];
    }
    else if (indexPath.row == 1)
    {
        UILabel *ID = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, 50)];
        [ID setBackgroundColor:[UIColor clearColor]];
        [ID setText:@"Dispute ID"];
        [ID setStyleClass:@"table_view_cell_textlabel_1"];
        [cell.contentView addSubview:ID];
        [cell.contentView addSubview:self.txtID];
    }
    else if (indexPath.row == 2)
    {
        UILabel *Date = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, 50)];
        [Date setBackgroundColor:[UIColor clearColor]];
        [Date setText:@"Dispute Date"];
        [Date setStyleClass:@"table_view_cell_textlabel_1"];
        [cell.contentView addSubview:Date];
        [cell.contentView addSubview:self.txtDate];
    }
    else if (indexPath.row == 3)
    {
        UILabel *ReviewDate = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, 50)];
        [ReviewDate setBackgroundColor:[UIColor clearColor]];
        [ReviewDate setText:@"Review Date"];
        [ReviewDate setStyleClass:@"table_view_cell_textlabel_1"];
        [cell.contentView addSubview:ReviewDate];
        [cell.contentView addSubview:self.txtReviewDate];
    }
    else if (indexPath.row == 4)
    {
        UILabel *ResolvedD = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, 50)];
        [ResolvedD setBackgroundColor:[UIColor clearColor]];
        [ResolvedD setText:@"Resolved Date"];
        [ResolvedD setStyleClass:@"table_view_cell_textlabel_1"];
        [cell.contentView addSubview:ResolvedD];
        [cell.contentView addSubview:self.txtResolvedD];
    }
    else if (indexPath.row == 5)
    {
        UILabel *Note = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, 50)];
        [Note setBackgroundColor:[UIColor clearColor]];
        [Note setText:@"Note"];
        [Note setStyleClass:@"table_view_cell_textlabel_1"];
        [cell.contentView addSubview:Note];
        [cell.contentView addSubview:self.txtNotes];
    }
    return cell;
}

-(void)Error:(NSError *)Error {
   
    /* UIAlertView *alert = [[UIAlertView alloc]
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
    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        [timer invalidate];
        [nav_ctrl performSelector:@selector(disable)];
        [nav_ctrl performSelector:@selector(reset)];
        
        NSMutableArray * arrNav = [nav_ctrl.viewControllers mutableCopy];
        for (int i = [arrNav count]; i > 1; i--) {
            [arrNav removeLastObject];
        }
        
        [nav_ctrl setViewControllers:arrNav animated:NO];
        Register *reg = [Register new];
        
        [nav_ctrl pushViewController:reg animated:YES];
        me = [core new];
        return;
    }
}

#pragma mark - file paths
- (NSString *)autoLogin
{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
