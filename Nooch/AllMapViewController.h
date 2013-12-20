//
//  AllMapViewController.h
//  Nooch
//
//  Created by Charanjit Singh Bhalla on 11/11/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "popSelect.h"
BOOL mapfilter;
NSString *filterString;
@interface AllMapViewController : UIViewController{
    NSMutableArray*arrFiltered;
}

@property (nonatomic , retain) NSMutableArray * pointsList;
- (IBAction)LeftBarbuttonPressed:(id)sender;

@end
