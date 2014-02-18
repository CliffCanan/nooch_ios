//
//  serve.h
//  Nooch
//
//  Created by Preston Hults on 2/6/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
@protocol serveD
@required
-(void)listen:(NSString *)result tagName:(NSString *)tagName;
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
-(void)addFund:(NSString*)amount;
-(void)deleteBank:(NSString*)bankId;
-(void)deleteCard:(NSString*)cardId;
-(void)forgotPass:(NSString *)email;
-(void)getBanks;
-(void)getCards;
-(void)getSettings;
-(void)getEncrypt:(NSString *)input;
-(void)getDetails:(NSString*)username;
//-(void)getLatestTrans
-(void)getMemIdFromuUsername:(NSString*)username;
-(void)getMemberIds:(NSArray*)input;
-(void)getNoteSettings;
-(void)getTargus;
-(void)getRecents;
-(void)privacyPolicy;
-(void)tos;
-(void)dupCheck:(NSString*)email;
//-(void)login:(NSString*)email password:(NSString*)pass;

-(void)makeBankPrimary:(NSString*)bankId;
-(void)makeCardPrimary:(NSString*)cardId;
-(void)memberDevice:(NSString *)deviceToken;
-(void)setEmailSets:(NSDictionary*)notificationDictionary;
-(void)setPushSets:(NSDictionary*)notificationDictionary;
-(void)newUser:(NSString *)email first:(NSString *)fName last:(NSString *)lName password:(NSString *)password pin:(NSString*)pin invCode:(NSString*)inv fbId:(NSString *)fbId ;
-(void)setSets:(NSDictionary*)settingsDictionary;
-(void)resetPassword:(NSString*)old new:(NSString*)new;
-(void)resetPIN:(NSString*)old new:(NSString*)new;
-(void)saveBank:(NSMutableDictionary *)bankDetails;
-(void)saveCard:(NSMutableDictionary*)cardDetails;
//-(void)sendInvite:(NSString)
-(void)setSharing:(NSString*)sharingValue;
-(void)pinCheck:(NSString*)memId pin:(NSString*)pin;
-(void)verifyBank:(NSString *)bankAcctId microOne:(NSString *)microOne microTwo:(NSString *)microTwo;
-(void)withdrawFund:(NSString*)amount;
//venturepact modification
-(void)getBankList;
-(void)login:(NSString*)email password:(NSString*)pass remember:(BOOL)isRem lat:(float)lat lon:(float)lng uid:(NSString*)strId;
-(void)validateInviteCode:(NSString *)inviteCode;
-(void)SendSMSApi:(NSString*)phoneNo msg:(NSString*)msgText;
-(void)GetReferralCode:(NSString*)memberid;
-(void)getInvitedMemberList:(NSString*)memId;
-(void)sendCsvTrasactionHistory:(NSString *)emailaddress;
-(void)ValidateBank:(NSString*)bankName routingNo:(NSString*)routingNumber;
-(void)getTotalReferralCode:(NSString *)inviteCode;
-(void)GetFeaturedNonprofit;
-(void)GetNonProfiltList;
-(void) GetAllWithdrawalFrequency;
-(void)getAutoWithDrawalSelectedOption;
-(void)GetAllWithdrawalTrigger;
-(void)SaveFrequency:(NSString*) withdrawalId type:(NSString*) type frequency: (float)withdrawalFrequency;
-(void)GetNonProfiltDetail:(NSString*)npId memberId:(NSString*)memberId;
-(void)histMore:(NSString*)type sPos:(NSInteger)sPos len:(NSInteger)len subType:(NSString*)subType;
-(void)histMoreSerachbyName:(NSString*)type sPos:(NSInteger)sPos len:(NSInteger)len name:(NSString*)name subType:(NSString*)subType;
-(void) LogOutRequest:(NSString*) memberId;
-(void)GetTransactionDetail:(NSString*)transactionId;
//-(void)SendEmailToNonNooch:(NSString*)emai;
-(void)MemberNotificationSettings:(NSDictionary*) memberNotificationSettings type:(NSString*)type;
-(void)MemberNotificationSettingsInput;
-(void)GetMemberStats:(NSString*)query;
-(void)getLocationBasedSearch:(NSString *)radius;
-(void)TransferMoneyToNonNoochUser:(NSDictionary*)transactionInput email:(NSString*)email;
-(void)SaveImmediateRequire:(BOOL)IsRequiredImmediatley;
-(void)ReferalCodeRequest:(NSString*)email;
-(void)RaiseDispute:(NSDictionary*)Input;
-(void)saveShareToFB_Twiitter:(NSString*)PostTo;
-(void)UpDateLatLongOfUser:(NSString*)lat lng:(NSString*)lng;
-(void)CancelRejectTransaction:(NSString*)transactionId resp:(NSString*)userResponse;
-(void)GetServerCurrentTime;
@end

//392f9c86-1651-4459-a6a9-d362fcfc4366 - nooch team
//e9821324-08ac-43f6-ad9d-5b6aabe8e8c3 - team nooch
