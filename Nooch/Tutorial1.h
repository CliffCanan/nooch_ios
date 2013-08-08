//
//  Tutorial1.h
//  Nooch
//
//  Created by Preston Hults on 9/13/12.
//  Copyright (c) 2012 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString *inviteCode;
bool fbCreate;

@interface Tutorial1 : UIViewController<UINavigationControllerDelegate,UITextFieldDelegate>{
    NSArray *backgroundArray;
    __weak IBOutlet UITextField *checkCodeField;
    __weak IBOutlet UITextField *reqInvField;
    __weak IBOutlet UIView *shadow;
    __weak IBOutlet UIView *requestInviteView;
    __weak IBOutlet UIView *enterInviteView;
    __weak IBOutlet UITextField *emailField;
    __weak IBOutlet UITextField *inviteCodeField;
    UIView *v;
}
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (nonatomic) IBOutlet UIImageView *background;
@property (nonatomic) int position;
@property (nonatomic,retain) NSArray *backgroundArray;
@property (nonatomic, retain) NSMutableArray *info1Array;
@property (nonatomic, retain) NSMutableArray *info2Array;
@property (nonatomic, retain) NSMutableArray *stepArray;
@property (nonatomic,retain) IBOutlet UISwipeGestureRecognizer *swiper1;
@property (nonatomic,retain) IBOutlet UISwipeGestureRecognizer *swiper2;
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImage;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *info2;
@property (weak, nonatomic) IBOutlet UILabel *info1;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UIImageView *image2;

@end
