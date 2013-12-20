//
//  serve.h
//  Nooch
//
//  Created by Preston Hults on 2/6/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONSerializer.h"
#import "CJSONDataSerializer.h"
#import "JSON.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MyCLController.h"
@protocol serveD
@required
-(void)listen:(NSString *)result tagName:(NSString *)tagName;
@end

@interface serve : NSObject <CLLocationManagerDelegate>{
    //venturepact modification
    

    NSMutableData *responseData;
    //NSMutableURLRequest *request;
    id<serveD> Delegate;
    NSString *tagName;

    NSString *latlng;
    CLLocationManager *locationManager;
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
    BOOL islogOutUnconditional;
    BOOL isloggedout;
}
@property(nonatomic,retain)NSString *Latitude;
@property(nonatomic,retain) NSString *Longitude;
@property(nonatomic,strong) CLLocationManager *locationManager;
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
-(void)getEncrypt:(NSString *)in;
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
-(void)newUser:(NSString *)email first:(NSString *)fName last:(NSString *)lName password:(NSString *)password pin:(NSString*)pin invCode:(NSString*)inv;
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
-(void)login:(NSString*)email password:(NSString*)pass remember:(BOOL)isRem lat:(float)lat lon:(float)lng;
-(void)validateInviteCode:(NSString *)inviteCode;
-(void)SendSMSApi:(NSString*)phoneNo msg:(NSString*)msgText;
-(void)GetReferralCode:(NSString*)memberid;
-(void)getInvitedMemberList:(NSString*)memId;
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
-(void)sendCsvTrasactionHistory:(NSString *)emailaddress;
-(void)ValidateBank:(NSString*)bankName routingNo:(NSString*)routingNumber;
-(void)getTotalReferralCode:(NSString *)inviteCode;
-(void) LogOutRequest:(NSString*) memberId;
//charanjit's edit 26/11
-(void)getAutoWithDrawalSelectedOption;
-(void)getLocationBasedSearch:(NSString *)radius;
-(void)GetAllWithdrawalTrigger;
-(void) GetAllWithdrawalFrequency;
-(void)SaveFrequency:(NSString*) withdrawalId type:(NSString*) type frequency: (float)withdrawalFrequency;
-(void)GetFeaturedNonprofit;
-(void)GetNonProfiltDetail:(NSString*)npId;
-(void)GetNonProfiltList;

@end

//392f9c86-1651-4459-a6a9-d362fcfc4366 - nooch team
//e9821324-08ac-43f6-ad9d-5b6aabe8e8c3 - team nooch
