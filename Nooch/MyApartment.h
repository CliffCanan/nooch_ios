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
@interface MyApartment : GAITrackedViewController<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,serveD>
{
    UIView * blankView;
    UIButton * arrow;
}
@end
