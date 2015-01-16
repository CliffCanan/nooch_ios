//
//  MyApartment.h
//  Nooch
//
//  Created by Clifford Canan on 1/14/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"

BOOL isBankAttached;
BOOL isFromPropertySearch;

@interface MyApartment : GAITrackedViewController<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,serveD>
{
}
@end
