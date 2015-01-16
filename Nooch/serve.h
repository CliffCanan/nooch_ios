//
//  serve.h
//  Nooch
//
//  Created by Preston Hults on 2/6/13.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MBProgressHUD.h"

@protocol serveD
@required
-(void)listen:(NSString *)result tagName:(NSString *)tagName;
-(void)Error:(NSError*)Error;
@end

@interface serve : NSObject {
    //venturepact modification
    NSMutableData *responseData;
    //NSMutableURLRequest *request;
    id<serveD> Delegate;
    NSString *tagName;
    NSString *latlng;
    // CLLocationManager *locationManager;
    MKPlacemark *placeMarker;
    NSString *country;
    NSString *city;
    NSString *state;
    NSString *zipcode;
    NSString *addressLine1;
    NSString *addressLine2;
    NSString *TransactionDate;
    NSString *Latitude;
    NSString *Longitude;
    NSString *Altitude;
    NSMutableDictionary*dictUsers;
    }
//@property(nonatomic,strong) CLLocationManager *locationManager;
@property (retain) id<serveD> Delegate;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSString *tagName;
@property(nonatomic,strong) MBProgressHUD *hud;

-(void)addFund:(NSString*)amount;
-(void)CancelMoneyRequestForExistingNoochUser:(NSString*)transactionId;
-(void)CancelMoneyTransferToNonMemberForSender:(NSString *)transactionId;
-(void)CancelMoneyRequestForNonNoochUser:(NSString*)transactionId;
-(void)CancelRejectTransaction:(NSString*)transactionId resp:(NSString*)userResponse;
-(void)deleteBank:(NSString*)bankId;
-(void)dupCheck:(NSString*)email;
-(void)forgotPass:(NSString *)email;
-(void)GetAllWithdrawalFrequency;
-(void)getAutoWithDrawalSelectedOption;
-(void)GetAllWithdrawalTrigger;
-(void)getAptDetails:(NSString*) memberId;
-(void)getBanks;
-(void)getBankList;
-(void)getSettings;
-(void)getEncrypt:(NSString *)input;
-(void)getDetails:(NSString*)username;
-(void)getInvitedMemberList:(NSString*)memId;
-(void)getLocationBasedSearch:(NSString *)radius;
-(void)GetMemberStats:(NSString*)query;
-(void)GetNonProfiltDetail:(NSString*)npId memberId:(NSString*)memberId;
-(void)GetTransactionDetail:(NSString*)transactionId;
-(void)getMemIdFromuUsername:(NSString*)username;
-(void)getMemIdFromPhoneNumber:(NSString*)phoneNumber;
-(void)getMemberIds:(NSArray*)input;
-(void)getNoteSettings;
-(void)getRecents;
-(void)GetReferralCode:(NSString*)memberid;
-(void)getTotalReferralCode:(NSString *)inviteCode;
-(void)GetFeaturedNonprofit;
-(void)GetNonProfiltList;
-(void)get_favorites;
-(void)GetKnoxBankAccountDetails;
-(void)getPendingTransfersCount;
-(void)GetServerCurrentTime;
-(void)histMore:(NSString*)type sPos:(NSInteger)sPos len:(NSInteger)len subType:(NSString*)subType;
-(void)histMoreSerachbyName:(NSString*)type sPos:(NSInteger)sPos len:(NSInteger)len name:(NSString*)name subType:(NSString*)subType;
-(void)login:(NSString*)email password:(NSString*)pass remember:(BOOL)isRem lat:(float)lat lon:(float)lng uid:(NSString*)strId;
-(void)loginwithFB:(NSString*)email FBId:(NSString*)FBId remember:(BOOL)isRem lat:(float)lat lon:(float)lng uid:(NSString*)strId;
-(void)LogOutRequest:(NSString*) memberId;
-(void)makeBankPrimary:(NSString*)bankId;
-(void)memberDevice:(NSString *)deviceToken;
-(void)MemberNotificationSettings:(NSDictionary*) memberNotificationSettings type:(NSString*)type;
-(void)MemberNotificationSettingsInput;
-(void)newUser:(NSString *)email first:(NSString *)fName last:(NSString *)lName password:(NSString *)password pin:(NSString*)pin invCode:(NSString*)inv fbId:(NSString *)fbId ;
-(void)pinCheck:(NSString*)memId pin:(NSString*)pin;
-(void)privacyPolicy;
-(void)ReferalCodeRequest:(NSString*)email;
-(void)RemoveKnoxBankAccount;
-(void)RaiseDispute:(NSDictionary*)Input;
-(void)resendEmail;
-(void)resetPassword:(NSString*)old new:(NSString*)new;
-(void)resetPIN:(NSString*)old new:(NSString*)new;
-(void)resendSMS;
-(void)SaveFrequency:(NSString*) withdrawalId type:(NSString*) type frequency: (float)withdrawalFrequency;
-(void)SaveImmediateRequire:(BOOL)IsRequiredImmediatley;
-(void)saveShareToFB_Twitter:(NSString*)PostTo;
-(void)saveMemberTransId:(NSDictionary*)trans;
-(void)SendReminderToRecepient:(NSString *)transactionId reminderType:(NSString*)reminderType;
-(void)show_in_search:(BOOL)show;
-(void)storeFB:(NSString*)fb_id isConnect:(NSString*)isconnect;
-(void)sendCsvTrasactionHistory:(NSString *)emailaddress;
-(void)setEmailSets:(NSDictionary*)notificationDictionary;
-(void)setPushSets:(NSDictionary*)notificationDictionary;
-(void)setSets:(NSDictionary*)settingsDictionary;
-(void)saveBank:(NSMutableDictionary *)bankDetails;
-(void)setSharing:(NSString*)sharingValue;
-(void)tos;
-(void)TransferMoneyToNonNoochUser:(NSDictionary*)transactionInput email:(NSString*)email;
-(void)UpDateLatLongOfUser:(NSString*)lat lng:(NSString*)lng;
-(void)ValidatePinNumberToEnterForEnterForeground:(NSString*)memId pin:(NSString*)pin;
-(void)verifyBank:(NSString *)bankAcctId microOne:(NSString *)microOne microTwo:(NSString *)microTwo;
-(void)validateInviteCode:(NSString *)inviteCode;
-(void)ValidateBank:(NSString*)bankName routingNo:(NSString*)routingNumber;
-(void)withdrawFund:(NSString*)amount;

@end
