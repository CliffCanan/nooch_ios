//
//  assist.h
//  Nooch
//
//  Created by Preston Hults on 1/25/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Constant.h"
#import "serve.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
NSTimer*timer;
BOOL profileGO;
bool histSafe;
bool limit;
bool loadingCheck;
bool needsUpdating;
NSString *histSearching;
@interface assist : NSObject<serveD>{
    NSMutableDictionary *usr;
    NSMutableDictionary *assosciateCache;
    NSMutableArray *histCache;
    NSMutableData *pic;
    NSMutableData *archivedData;
    NSMutableData *responseData;
    NSMutableArray *sortedHist;
    //venturepact
    BOOL isPrimaryBankVerified;
    BOOL islogout;
    UIImage*imageOBJFortransfer;
    BOOL islocationAllowed;
    BOOL isNeed;
    BOOL isUserSuspended;
    NSMutableArray*arrRequestMultiple;
    BOOL isMutipleRequest;
    BOOL isSecondBankVerified;
    BOOL isPOP;
    NSString*passValue;
}
//@property(nonatomic,retain)NSTimer*timer;
@property (nonatomic, retain) ACAccountStore *accountStore;
@property (nonatomic, retain) ACAccount *facebookAccount;
@property (nonatomic, retain) ACAccount *twitterAccount;
@property (nonatomic) bool fbAllowed;
@property (nonatomic) bool twitterAllowed;
//venturepact
@property(nonatomic,strong)NSArray*arrRecordsCheck;
-(NSMutableDictionary*)usr;
-(NSMutableArray*)hist;
-(NSMutableData*)pic;
-(NSMutableArray*)allHist;
-(NSMutableDictionary*)assos;
-(void)addAssos:(NSMutableArray*)additions;
-(NSMutableArray*)assosSearch:(NSString*)searchText;
-(void)histPoll;
-(void)histUpdate;
-(void)histMore:(NSString*)type sPos:(NSInteger)sPos len:(NSInteger)len;
-(NSMutableArray*)histFilter:(NSString*)filterPick;
-(void)birth;
-(void)stamp;
-(void)death:(NSString*)path;
-(BOOL)isAlive:(NSString*)path;
-(BOOL)isClean:(id)object;
-(UIColor*)hexColor:(NSString*)hex;
-(NSString *)path:(NSString *)type;
-(id)cleanForSave:(id)array;
-(UIFont *)nFont:(NSString*)weight size:(int)size;
-(void)fetchPic;
-(void)getCards;
-(void)getBanks;
-(void)getSettings;

-(void)setTranferImage:(UIImage*)image;
+(assist*)shared;
-(UIImage*)getTranferImage;
-(BOOL)isloggedout;
-(void)setisloggedout:(BOOL)islog;
-(BOOL)isBankVerified;
-(void)setBankVerified:(BOOL)istrue;
-(BOOL)isSecondBankVerified;
-(void)setSecondBankVerified:(BOOL)istrue;
-(BOOL)isPOP;
-(void)setPOP:(BOOL)istrue;
-(BOOL)islocationAllowed;
-(void)setlocationAllowed:(BOOL)istrue;
-(BOOL)needsReload;
-(void)setneedsReload:(BOOL)istrue;
-(BOOL)getSuspended;
-(void)setSusPended:(BOOL)istrue;
-(NSMutableArray*)getArray;
-(void)setArray:(NSMutableArray*)arr;
-(BOOL)isRequestMultiple;
-(void)setRequestMultiple:(BOOL)istrue;
-(NSString*)getPass;
-(void)setPassValue:(NSString*)value;

@end
