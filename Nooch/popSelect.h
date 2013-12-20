//
//  popSelect.h
//  Nooch
//
//  Created by Preston Hults on 2/27/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
bool memoList;

@interface popSelect : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    UITableView *popList;
}

@end
