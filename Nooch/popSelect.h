//
//  popSelect.h
//  Nooch
//
//  Created by Preston Hults on 2/27/13.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
bool memoList;
BOOL isFilterSelected;
@interface popSelect : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    UITableView *popList;
}

@end
