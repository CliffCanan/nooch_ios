//
//  assist.h
//  Nooch
//
//  Created by Preston Hults on 1/25/13.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Constant.h"
#import "serve.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
NSTimer*timer;
bool histSafe;
bool needsUpdating;
NSString *histSearching;
@interface assist : NSObject<serveD>{
    NSArray*ArrAllContacts;
    NSMutableDictionary *usr;
    NSMutableDictionary *assosciateCache;
    NSMutableArray *arrRequestMultiple;
    NSMutableArray *histCache;
    NSMutableArray *sortedHist;
    NSMutableData *archivedData;
    NSMutableData *pic;
    NSMutableData *responseData;
    NSString*passValue;
    UIImage*imageOBJFortransfer;
    BOOL isPrimaryBankVerified;
    BOOL islogout;
    BOOL islocationAllowed;
    BOOL isNeed;
    BOOL isUserSuspended, isProfileCompleteAndValidated;
    BOOL isMutipleRequest;
    BOOL isPOP;
    BOOL isLoginFromOther;
}

@property(nonatomic, retain) ACAccountStore *accountStore;
@property(nonatomic, retain) ACAccount *facebookAccount;
@property(nonatomic, retain) ACAccount *twitterAccount;
@property(nonatomic) bool fbAllowed;
@property(nonatomic) bool twitterAllowed;
@property(nonatomic,strong)NSArray*arrRecordsCheck;

+(assist*)shared;

-(NSMutableArray*)allHist;
-(NSMutableArray*)assosSearch:(NSString*)searchText;
-(NSMutableArray*)assosAll;
-(NSMutableArray*)getArray;
-(NSMutableArray*)hist;
-(NSMutableArray*)histFilter:(NSString*)filterPick;

-(NSMutableData*)pic;
-(NSMutableDictionary*)usr;
-(NSMutableDictionary*)assos;

-(NSString*)getPass;
-(NSString *)path:(NSString *)type;

-(UIColor*)hexColor:(NSString*)hex;
-(UIFont *)nFont:(NSString*)weight size:(int)size;
-(UIImage*)getTranferImage;

-(BOOL)isAlive:(NSString*)path;
-(BOOL)isClean:(id)object;
-(BOOL)islocationAllowed;
-(BOOL)isloggedout;
-(BOOL)isloginFromOther;
-(BOOL)isPOP;
-(BOOL)isProfileCompleteAndValidated;
-(BOOL)isRequestMultiple;
-(BOOL)checkIfLocAllowed;
-(BOOL)checkIfTouchIdAvailable;
-(BOOL)getSuspended;
-(BOOL)needsReload;

-(id)cleanForSave:(id)array;

-(void)addAssos:(NSMutableArray*)additions;
-(void)birth;
-(void)death:(NSString*)path;
-(void)histMore:(NSString*)type sPos:(NSInteger)sPos len:(NSInteger)len;
-(void)stamp;
-(void)fetchPic;
-(void)getSettings;
-(void)getAcctInfo;
-(void)SaveAssos:(NSMutableArray*)additions;
-(void)setArray:(NSMutableArray*)arr;
-(void)setisloggedout:(BOOL)islog;
-(void)setIsloginFromOther:(BOOL)islog;
-(void)setlocationAllowed:(BOOL)istrue;
-(void)setneedsReload:(BOOL)istrue;
-(void)setPassValue:(NSString*)value;
-(void)setPOP:(BOOL)istrue;
-(void)setRequestMultiple:(BOOL)istrue;
-(void)setSusPended:(BOOL)istrue;
-(void)setTranferImage:(UIImage*)image;

@end
