//
//  TransactionDetails.h
//  Nooch
//
//  Created by crks on 10/4/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "serve.h"

@interface TransactionDetails : UIViewController<serveD,UIAlertViewDelegate>{
    GMSMapView *mapView_;
}
- (id)initWithData:(NSDictionary *)trans;

@end
